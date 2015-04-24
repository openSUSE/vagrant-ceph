
module Vagrant
  class Hosts

    def initialize(host_config, selected = 'public')
      @host_config = host_config
      @selected = selected
      File.open("hosts", "w") do |file|
        static_header(file)
        entries = reorganize
        entries.keys.each do |section|
          entries[section].each do |entry|
            file.puts entry
          end
          file.puts
        end
      end
    end

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

        # special IPv6 addresses
        ::1             localhost ipv6-localhost ipv6-loopback

        fe00::0         ipv6-localnet

        ff00::0         ipv6-mcastprefix
        ff02::1         ipv6-allnodes
        ff02::2         ipv6-allrouters
        ff02::3         ipv6-allhosts

      END

    end

    def reorganize
      networks = {}
      @host_config.keys.each do |hostname|
        @host_config[hostname].keys.each do |network|
          networks[network] ||= []
          entry = "%-16s" % "#{@host_config[hostname][network]}"
          entry += "#{hostname}-#{network}"
          entry += " #{hostname}" if (network == @selected)
          networks[network] << entry
        end
      end
      networks
    end

    def update(node)
      tmp_hosts = "/home/vagrant/hosts"
      node.vm.provision 'file', source: "hosts", destination: "#{tmp_hosts}"
      node.vm.provision 'shell', inline: "mv #{tmp_hosts} /etc/hosts"
    end
  end
end
