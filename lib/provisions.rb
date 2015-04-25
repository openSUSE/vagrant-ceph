
# Namespace for helper routines
module Vagrant

  # Adds repositories to a VM
  class Repos

    # Builds an array of commands to add each repo.
    #
    #   node - vagrant provider
    #   config - yaml configuration
    #   box - vagrant box name
    def initialize(node, config, box)
      @node = node
      @cmds = []
      config[INSTALLATION][box]['repos'].keys.each do |repo|
        # Use shell short circuit to determine if repo already exists
        @cmds << "zypper lr \'#{repo}\' | grep -sq ^Name || zypper ar \'#{config[INSTALLATION][box]['repos'][repo]}\' \'#{repo}\'"
      end
    end

    # Runs all the commands in a single shell
    def add
      @node.vm.provision 'shell', inline: @cmds.join('; ') 
    end
  end

  # Installs additional packages
  class Packages

    # Saves arguments
    #
    #   node - vagrant provider
    #   packages - an array of package names
    def initialize(node, packages)
      @node = node
      @packages = packages
    end

    # Runs necessary zypper command, automatically trust repo
    def install
      cmd = "zypper --gpg-auto-import-keys -n in #{@packages.join(' ')}"
      @node.vm.provision 'shell', inline: cmd
    end
  end

  # Manage keys for root account
  class Keys

    # Saves arguments and call setup
    #
    #   node - vagrant provider
    #   servers - all the hostnames in the cluster
    def initialize(node, servers)
      @node = node
      @servers = servers
      setup
    end

    # Copy static private/public key to root account.  Run necessary shell 
    # commands in a single call. 
    def setup
      [ 'files/id_ecdsa', 'files/id_ecdsa.pub' ].each do |file|
        @node.vm.provision 'file', source: file, destination: "/home/vagrant/#{File.basename(file)}"
      end
      steps = <<-END.gsub(/^ {8}/, '')
        mkdir -p /root/.ssh
        mv /home/vagrant/id_ecdsa /root/.ssh
        mv /home/vagrant/id_ecdsa.pub /root/.ssh
        cp /root/.ssh/id_ecdsa.pub /root/.ssh/authorized_keys
        chmod 0600 /root/.ssh/id_ecdsa
      END
      @node.vm.provision 'shell', inline: steps
    end

    # Log into each machine and accept which generates the known_hosts
    def authorize
      @servers.each do |server|
        cmd = "ssh -oStrictHostKeyChecking=no #{server} exit"
        @node.vm.provision 'shell', inline: cmd
      end
    end
  end

end
