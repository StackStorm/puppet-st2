# -*- mode: ruby -*-
# vi: set ft=ruby :

# Description:
#   This is a Vagrant file for developers to quickly get started with development
#   on the puppet-st2 module.
#
# Usage:
#   - Install VirtualBox (https://www.virtualbox.org/manual/ch02.html)
#     - OR Install KVM/libvirt (https://www.linuxtechi.com/install-kvm-hypervisor-on-centos-7-and-rhel-7/)
#   - Install Vagrant (https://www.vagrantup.com/docs/installation/)
#
#   - Start vagrant VM
#       vagrant up
#
#   - In another terminal start up the rsync-auto daemon.
#     Now, if you make any changes the code will be copied into the VM. This way you can
#     re-run Puppet with your latest code without having to manually copy the code in:
#       vagrant rsync-auto
#
#   - Login to vagrant VM
#       vagrant ssh
#
#   - Fix sudoers directory
#       sudo su -
#       chmod 440 -R /etc/sudoers.d
#
#   - Run puppet to install StackStorm
#       puppet apply -e "include ::st2::profile::fullinstall"
#
#   - Keep editing files locally and re-running puppet with the command above

# hostname of the VM
hostname   = ENV['HOSTNAME'] ? ENV['HOSTNAME'] : 'puppet-st2-vagrant'

# We also support the :libvirt provider for CentOS / RHEL folks
provider   = ENV['PROVIDER'] ? ENV['PROVIDER'] : :libvirt

# The following boxes will work for both :virtualbox and :libvirt providers
#  - centos/6
#  - centos/7
#  - generic/1404
#  - generic/1604
box        = ENV['BOX'] ? ENV['BOX'] : 'centos/7'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "st2" do |st2|
    # Box details
    st2.vm.box = "#{box}"
    st2.vm.hostname = "#{hostname}"

    # Box Specifications
    if provider == :virtualbox
      st2.vm.provider :virtualbox do |vb|
        vb.name = "#{hostname}"
        vb.memory = 2048
        vb.cpus = 2
        vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
      end
    elsif provider == :libvirt
      st2.vm.provider :libvirt do |lv|
        lv.host = "#{hostname}"
        lv.memory = 2048
        lv.cpus = 2
        lv.uri = "qemu:///system"
        lv.storage_pool_name = "images"
      end
    else
      raise RuntimeError.new("Unsupported provider: #{provider}")
    end

    # sync code into box for development
    # To setup automatic rsyncing, in another shell session you need to run:
    #   vagrant rsync-auto
    #
    # https://www.vagrantup.com/docs/cli/rsync-auto.html
    st2.vm.synced_folder ".", "/vagrant", type: 'rsync', rsync__auto: true
    
    # Start shell provisioning.
    st2.vm.provision "shell" do |s|
      s.path = "build/scripts/install_puppet.sh"
      s.privileged = false
    end
  end
end
