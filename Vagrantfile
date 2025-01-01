#vm_image: 'ubuntu/jammy64'
require 'fileutils'

dir = File.dirname(File.expand_path(__FILE__))
ansible_script = '#{dir}/ansible-vm/'

VM_STAT = {
  "ansible-vm" => {ram: 1000, cpus: 1, ip: '192.168.56.10', vm_image: 'ubuntu/jammy64', host_port: 2721},
  #"gitlab-vm" => {ram: 6084, cpus: 3, ip: '192.168.56.11', vm_image: 'ubuntu/jammy64', host_port: 2722},
  #"dns-vm" => {ram: 2048, cpus: 2, ip: '192.168.56.16', vm_image: 'ubuntu/jammy64', host_port: 2729},
  #"nfs-vm" => {ram: 2046, cpus: 2, ip: '192.168.56.12', vm_image: 'ubuntu/jammy64', host_port: 2723},
  "kube-node-1" => {ram: 1500, cpus: 2, ip: '192.168.56.13', vm_image: 'ubuntu/jammy64', host_port: 2724},
  "kube-node-2" => {ram: 1500, cpus: 2, ip: '192.168.56.14', vm_image: 'ubuntu/jammy64', host_port: 2725},
  "kube-vm" => {ram: 2048, cpus: 4, ip: '192.168.56.15', vm_image: 'ubuntu/jammy64', host_port: 2726},
  "kube-test-vm" => {ram: 2048, cpus: 4, ip: '192.168.56.19', vm_image: 'ubuntu/jammy64', host_port: 2729},
  "test-node-1" => {ram: 2568, cpus: 2, ip: '192.168.56.18', vm_image: 'ubuntu/jammy64', host_port: 27257},
  "test-node-2" => {ram: 2048, cpus: 2, ip: '192.168.56.17', vm_image: 'ubuntu/jammy64', host_port: 27258}  
}

# version 2
Vagrant.configure("2") do |config|
  VM_STAT.each do |vm_name, info|
    
    # Check and create folders 
    full_path = dir + '/' + vm_name + '/'
    unless File.directory?(full_path)
           FileUtils.mkdir_p(full_path)
           puts "folder created dest: " + full_path
    end 
  
    # Define vm box
    config.vm.box = "#{info[:vm_image]}"
    config.vm.define "#{vm_name}" do |node|
      node.vm.provider "virtualbox" do |vb|
        vb.name = "#{vm_name}"
        vb.memory = "#{info[:ram]}"
        vb.cpus = "#{info[:cpus]}"
        vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
        vb.customize ["modifyvm", :id, "--vram", "80"]
        vb.gui  = true
      end 
        
      # Define ip parameters 
      node.vm.hostname = "#{vm_name}"
      node.vm.network "private_network", ip: "#{info[:ip]}"
      node.vm.network "forwarded_port", guest: 22, host: "#{info[:host_port]}"

      # Define sync folder for vm
      full_path = dir + '/' + vm_name + '/'
      #puts full_path
      node.vm.synced_folder full_path, '/vagrant'        
    end

    # VM PROVISIONING

    # provision ansible vm
    if 'ansible-vm'.include?(vm_name)
      config.vm.define "ansible-vm" do |ansible|
        ansible.vm.provision "ansible-setup", type: "shell", path: dir + '/ansible-vm/install-ansible.sh'
      end
    end
    
    # Install bind dns on vms RUN : NEVER (manual run)
    config.vm.provision "dns-setup", type: "shell", run: "never", path: dir + \
    '/ansible-vm/install-bind.sh'
    
    config.vm.provision "gui-setup", type: "shell", path: dir + '/ansible-vm/install-gui.sh'
      
    # install docker & kubernetes on controller (kube-vm)
    if ['kube-vm', 'kube-test-vm'].include?(vm_name)
      #config.ssh.private_key_path = dir + '\.vagrant\machines\kube-vm\virtualbox\private_key'
      config.vm.provision "file", source: dir + '/ansible-vm/tower/ansible.pub', \
      destination: "/home/vagrant/.ssh/ansible.pub"
      config.vm.provision :shell, :inline => \
      "cat /home/vagrant/.ssh/ansible.pub >> /home/vagrant/.ssh/authorized_keys"
    end

    # install docker & kube on nodes
    if ['kube-node-1', 'kube-node-2'].include?(vm_name)
      config.vm.provision "file", source: dir + '/ansible-vm/tower/ansible.pub', \
      destination: "/home/vagrant/.ssh/ansible.pub"
      config.vm.provision :shell, :inline => \
      "cat /home/vagrant/.ssh/ansible.pub >> /home/vagrant/.ssh/authorized_keys"
    end
    
    if ['test-node-1', 'test-node-2'].include?(vm_name)
      print "#{info[:ip]}"
      config.vm.network "forwarded_port", guest: 5002, host: 8080
      config.vm.provision "file", source: dir + '/ansible-vm/tower/ansible.pub', \
      destination: "/home/vagrant/.ssh/ansible.pub"
      config.vm.provision :shell, :inline => \
      "cat /home/vagrant/.ssh/ansible.pub >> /home/vagrant/.ssh/authorized_keys"
    end
  end      
end  