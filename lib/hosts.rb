require 'tempfile'

# Namespace for related helper routines
module Vagrant

  # Generates a host file from the config.yml and propogates to the individual
  # virtual machines
  class Hosts

    # Creates a hosts file in the current directory.  Populates with reorganized
    # entries.
    #
    #   host_config - hash of hosts containing interfaces mapped to addresses
    #   selected - default network for short hostname
    def initialize(host_config, selected = 'public', domain = nil, aliases = {})
      @host_config = host_config
      @selected = selected
      @domain = domain
      @aliases = aliases
      @tmpfile = Tempfile.new("vagrant-ceph-etc-hosts")
      @tmpfile.chmod(0644)
      static_header(@tmpfile)
      entries = reorganize
      entries.keys.each do |section|
        entries[section].each do |entry|
          @tmpfile.puts entry
        end
        @tmpfile.puts
      end
      @tmpfile.fsync
      @tmpfile.close
    end

    # Produces the header portion of the hosts file
    def static_header(file)
      file.puts <<-END.gsub(/^ {8}/, '')
        #
        # hosts         This file describes a number of hostname-to-address
        #               mappings for the TCP/IP subsystem.  It is mostly
        #               used at boot time, when no name servers are running.
        #               On small systems, this file can be used instead of a
        #               "named" name server.
        # Syntax:
        #    
        # IP-Address  Full-Qualified-Hostname  Short-Hostname
        #

        127.0.0.1       localhost

        fe00::0         ipv6-localnet

        ff00::0         ipv6-mcastprefix
        ff02::1         ipv6-allnodes
        ff02::2         ipv6-allrouters
        ff02::3         ipv6-allhosts

      END

    end

    # Creates entries with address and hostname-networkname.  Sorts by
    # networks.  Adds short hostnames to selected network.
    def reorganize
      networks = {}
      @host_config.keys.each do |hostname|
        @host_config[hostname].keys.each do |network|
          networks[network] ||= []
          entry = "%-16s" % "#{@host_config[hostname][network]}"
          entry += "#{hostname}-#{network}"
          entry += " #{hostname}" if (network == @selected)
          entry += " #{hostname}.#{@domain}" if (@domain)
          entry += " #{@aliases[hostname]}" if (@aliases.has_key?(hostname))
          networks[network] << entry
        end
      end
      networks
    end

    # Calls vagrant provisioning to copy the hosts file to the VM.  This is 
    # done in two steps since the copy is unprivileged.
    def update(node)
      tmp_hosts = "/home/vagrant/hosts"
      node.vm.provision 'file', source: @tmpfile.path, destination: "#{tmp_hosts}"
      node.vm.provision 'shell', inline: "mv #{tmp_hosts} /etc/hosts"
    end

    def self.check_for_ssh_keys
      unless (File.exists?("#{ENV['HOME']}/.ssh/id_rsa") or
              File.exists?("#{ENV['HOME']}/.ssh/id_dsa")) then
        raise "Libvirt needs access to configure/start virtual machines.  One 
          method is giving your account root access via ssh key.  Generate a 
          key pair and add the public key to /root/.ssh/authorized_keys.
        
          Run 'ssh-add' to avoid typing the passphrase continually.  "
      end
    end
  end
end
