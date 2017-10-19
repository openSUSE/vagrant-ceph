require 'open3'
##include Archive::Tar

# Namespace for helper routines
module Vagrant

  # Adds repositories to a VM
  class Repos

    # Builds an array of commands to add each repo.
    #
    #   node - vagrant provider
    #   repos - hash of repo names and urls
    def initialize(node, repos)
      @node = node
      @cmds = []
      unless repos.nil? then
        repos.keys.each do |repo|
          # Use shell short circuit to determine if repo already exists
          @cmds << "zypper lr \'#{repo}\' | grep -sq ^Name || zypper ar -f \'#{repos[repo]}\' \'#{repo}\'"
        end
      end
    end

    def clean
      @node.vm.provision 'shell', inline: "sudo rm -f /etc/zypp/repos.d/*"
    end

    # Runs all the commands in a single shell
    def add
      @node.vm.provision 'shell', inline: @cmds.join('; ') 
    end
  end

  # Adds SUSEConnect Repos
  class SUSEConnect
    def initialize(node, commands)
      @node = node
      @cmds = []
      unless commands.nil? then
        commands.each do |cmd|
          @cmds << "#{cmd}"
        end
      end
    end

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
    def initialize(node, host, packages)
      @node = node
      @host = host
      @packages = packages
    end

    # Install packages for destined for all hosts and this host specifically
    def install
      install_all
      install_host
    end

    # Runs necessary zypper command, automatically trust repo
    def install_all
      cmd = "zypper --gpg-auto-import-keys -n in #{@packages['all'].join(' ')}"
      @node.vm.provision 'shell', inline: cmd
    end

    # Runs necessary zypper command, automatically trust repo
    def install_host
      unless (@packages[@host].nil?) then
        cmd = "zypper --gpg-auto-import-keys -n in #{@packages[@host].join(' ')}"
        @node.vm.provision 'shell', inline: cmd
      end
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
      [ "/home/#{ENV['USER']}/.ssh/id_rsa.pub", 'files/id_ecdsa', 'files/id_ecdsa.pub' ].each do |file|
        @node.vm.provision 'file', source: file, destination: "/home/vagrant/#{File.basename(file)}"
      end
      steps = <<-END.gsub(/^ {8}/, '')
        mkdir -p /root/.ssh
        mv /home/vagrant/id_ecdsa /root/.ssh/
        cat /home/vagrant/id_ecdsa.pub >> /root/.ssh/authorized_keys
        mv /home/vagrant/id_ecdsa.pub /root/.ssh
        cat /home/vagrant/id_rsa.pub >> /root/.ssh/authorized_keys
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

  # Copy files from files/install_mode to the virtual machine.  Effectively,
  # a poor man's patch after package installation to allow quick experimenting
  # until the real solution is decided
  class Files

    # Saves arguments
    #
    #   node - vm provider
    #   install_mode - type of installation
    #   host - hostname
    #   files - boolean determining if tree should be copied
    #   box - box name / indentifier in config
    #   configuration / tiny/default/small
    def initialize(node, install_mode, host, files, box, configuration)
      @node = node
      @install_mode = install_mode
      @host = host
      @files = files
      @box = box
      @configuration = configuration
    end

    # Creates a tar file, uses vagrant's copy command and then extracts
    # the file on the virtual machine.  Copies both subdirectories of all
    # and host specific trees.
    def copy
      unless (@files.nil?) then
        [ 'all', @host ].each do |subdir|
          unless (@files[subdir].nil?) then
            # check if enabled
            if (@files[subdir]) then
              tar_file = tar(subdir)
              vm_tar_file = "/home/vagrant/#{File.basename(tar_file)}"
              @node.vm.provision 'file', source: tar_file,
                destination: vm_tar_file
              untar(vm_tar_file)
            if (@files['customized']) then
              dir_name = "#{@box}_#{@configuration}"
              if (File.directory?("files/#{@install_mode}/#{dir_name}")) then
                tar_file = tar(dir_name)
                vm_tar_file = "/home/vagrant/#{File.basename(tar_file)}"
                @node.vm.provision 'file', source: tar_file,
                  destination: vm_tar_file
                untar(vm_tar_file)
              end
            end
          end
        end
      end
      end
    end

    # Change directory and generate tar file via Minitar
    #
    #   subdir - either 'all' or hostname 
    def tar(subdir)
      filename = "/tmp/#{@install_mode}-#{subdir}.tar"
      File.open(filename, "wb") do |tar|
        dir = "files/#{@install_mode}/#{subdir}"
        if (File.directory?(dir)) then
          Dir.chdir(dir) do
            cmd = "tar cf #{filename} *"
            Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
              puts stdout.readlines
              puts stderr.readlines
              exit unless wait_thr.value.success?
            end
            #Minitar.pack('*', tar)
          end
        end
      end
      filename
    end

    # Extract files in the virtual machine
    #
    #   tar_file - path to tar file
    def untar(tar_file)
      cmd = "tar --no-overwrite-dir -C / -xf #{tar_file}"
      @node.vm.provision 'shell', inline: cmd
    end
  end

  # Runs necessary commands
  class Commands

    # Saves arguments
    #
    #   node - vm provider
    #   host - hostname
    #   commands - hash of all and hosts to commands
    def initialize(node, host, commands)
      @node = node
      @host = host
      @commands = commands
    end

    def run
      [ 'all', @host].each do |group|
        unless (@commands[group].nil?) then
          @commands[group].each do |cmd|
            @node.vm.provision 'shell', inline: cmd
          end
        end
      end
    end

  end

end
