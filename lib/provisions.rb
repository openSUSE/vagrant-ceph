

module Vagrant

  class Repos

    def initialize(node, config, box)
      @node = node
      @cmds = []
      config[INSTALLATION][box]['repos'].keys.each do |repo|
        @cmds << "zypper lr \'#{repo}\' | grep -sq ^Name || zypper ar \'#{config[INSTALLATION][box]['repos'][repo]}\' \'#{repo}\'"
      end
    end

    def add
      @node.vm.provision 'shell', inline: @cmds.join('; ') 
    end
  end

  class Packages

    def initialize(node, packages)
      @node = node
      @packages = packages
    end

    def install
      cmd = "zypper --gpg-auto-import-keys -n in #{@packages.join(' ')}"
      @node.vm.provision 'shell', inline: cmd
    end
  end

  class Keys
    def initialize(node, servers)
      @node = node
      @servers = servers
      setup
    end

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

    def authorize
      @servers.each do |server|
        cmd = "ssh -oStrictHostKeyChecking=no #{server} exit"
        @node.vm.provision 'shell', inline: cmd
      end
    end
  end

end
