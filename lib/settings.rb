def common_settings(node, config, name)
      # Disable default vagrant folder
      # Note: comment out the following line to have a shared folder but you
      # will be prompted for the root password of the host machine to configure
      # your NFS server
      node.vm.synced_folder ".", "/vagrant", disabled: true

      node.vm.hostname = name

      # Ceph has three networks
      networks = config[CONFIGURATION]['nodes'][name]
      node.vm.network :private_network, ip: networks['management']
      node.vm.network :private_network, ip: networks['public']
      node.vm.network :private_network, ip: networks['cluster']
end

def libvirt_settings(provider, config, name)
        provider.host = 'localhost'
        provider.username = 'root'


        # Use DSA key if available, otherwise, defaults to RSA
        provider.id_ssh_key_file = 'id_dsa' if File.exists?("#{ENV['HOME']}/.ssh/id_dsa")
        provider.connect_via_ssh = true

        # Libvirt pool and prefix value
        provider.storage_pool_name = 'default'
        #l.default_prefix = ''

        # Memory defaults to 512M, allow specific configurations 
        unless (config[CONFIGURATION]['memory'].nil?) then
          unless (config[CONFIGURATION]['memory'][name].nil?) then
            provider.memory = config[CONFIGURATION]['memory'][name]
          end
        end

        # Set cpus to 2, allow specific configurations
        provider.cpus =  2
        unless (config[CONFIGURATION]['cpu'].nil?) then
          unless (config[CONFIGURATION]['cpu'][name].nil?) then
            provider.cpus = config[CONFIGURATION]['cpu'][name] 
          end
        end

        # Raw disk images to simulate additional drives on data nodes
        unless (config[CONFIGURATION]['disks'].nil?) then
          unless (config[CONFIGURATION]['disks'][name].nil?) then
            disks = config[CONFIGURATION]['disks'][name]
            unless (disks['hds'].nil?) then
              (1..disks['hds']).each do |d|
                provider.storage :file, size: '20G', type: 'qcow2'
              end
            end
            unless (disks['ssds'].nil?) then
              (1..disks['ssds']).each do |d|
                provider.storage :file, size: '20G', type: 'qcow2'
              end
            end
          end
        end

end

def virtbox_settings(provider, config, name)
        unless (config[CONFIGURATION]['memory'].nil?) then
          unless (config[CONFIGURATION]['memory'][name].nil?) then
            provider.customize [ "modifyvm", :id, "--memory", 
                           config[CONFIGURATION]['memory'][name] ]
          end
        end

        provider.cpus = 2
        unless (config[CONFIGURATION]['cpu'].nil?) then
          provider.cpus = config[CONFIGURATION]['cpu'][name] 
        end

        # Default interfaces will be eth0, eth1, eth2 and eth3
        provider.customize [ "modifyvm", :id, "--nictype1", "virtio" ]
        provider.customize [ "modifyvm", :id, "--nictype2", "virtio" ]
        provider.customize [ "modifyvm", :id, "--nictype3", "virtio" ]
        provider.customize [ "modifyvm", :id, "--nictype4", "virtio" ]

        unless (config[CONFIGURATION]['disks'].nil?) then
          unless (config[CONFIGURATION]['disks'][name].nil?) then
            disks = config[CONFIGURATION]['disks'][name]
            FileUtils.mkdir_p("#{Dir.home}/disks")
            unless (disks['hds'].nil?) then
              (1..disks['hds']).each do |d|
                file = "#{Dir.home}/disks/#{name}-#{d}"
                provider.customize [ "createhd", "--filename", file, "--size", "1100" ]
                provider.customize [ "storageattach", :id, "--storagectl", "SCSI Controller", 
                               "--port", d, 
                               "--device", 0, 
                               "--type", "hdd", 
                               "--medium", file + ".vdi" ]
              end
            end
            unless (disks['ssds'].nil?) then
              (1..disks['ssds']).each do |d|
                file = "#{Dir.home}/disks/#{name}-#{d}"
                provider.customize [ "createhd", "--filename", file, "--size", "1000" ]
                provider.customize [ "storageattach", :id, "--storagectl", "SCSI Controller", 
                               "--port", d, 
                               "--device", 0, 
                               "--type", "hdd", 
                               "--medium", file + ".vdi" ]
              end
            end
          end
        end

end

