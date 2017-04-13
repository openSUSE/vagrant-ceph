# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
require "pp"


require_relative "lib/settings.rb"
require_relative "lib/provisions.rb"


# create config and default, merge both.
default_config_file =  "config/default.yml"
default_config = YAML.load_file(default_config_file)

if File.exists?("#{ENV['VC_CONFIG']}")
    config_file = "#{ENV['VC_CONFIG']}"
    user_config = YAML.load_file(config_file)
else
    user_config = {}
end

config = default_config.merge(user_config)

def provisioned?(vm_name='default', provider='libvirt')
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

def provisioning(node, config, name)

      # Run prep-commands
      commands = Vagrant::Commands.new(node, name, config["prep-commands"])
      commands.run

      # Add missing repos
      repos = Vagrant::Repos.new(node, config['repos'])
      if ENV.has_key?("CLEAN_ZYPPER_REPOS") or !provisioned?(name)
        repos.clean
      end
      repos.add

      # Copy custom files
      # files = Vagrant::Files.new(node, name, config["files"])
      # files.copy

      # Install additional/unique packages
      pkgs = Vagrant::Packages.new(node, name, config["packages"])
      pkgs.install

      # Run commands
      commands = Vagrant::Commands.new(node, name, config["commands"])
      commands.run

end

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = config["box"]

  nodes = config["nodes"]

  nodes.each_key do |name|
    vm_name = name

    vconfig.vm.define vm_name do |node|
      common_settings(node, config, name)

      node.vm.provider :libvirt do |l|
        libvirt_settings(l, config, name)
      end

      provisioning(node, config, name)

    end
  end

end
