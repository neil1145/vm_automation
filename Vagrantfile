require 'fileutils'
require 'securerandom'

dir = File.dirname(File.expand_path(__FILE__))
SSH_KEYS_DIR = "#{dir}/.vm_keys"

# Ensure SSH keys directory exists
FileUtils.mkdir_p(SSH_KEYS_DIR) unless Dir.exist?(SSH_KEYS_DIR)

VM_STAT = {
  "ansible-vm" => {
    ram: 1000, 
    cpus: 1,
    ip: '192.168.56.10',
    role: 'ansible_controller',
    host_port: 2721,
    additional_ports: []  # Ansible controller typically doesn't need extra ports
  },
  "kube-vm" => {
    ram: 2048, 
    cpus: 4,
    ip: '192.168.56.15',
    role: 'k8s_master',
    host_port: 2726,
    additional_ports: [
      {guest: 6443, host: 6443},     # Kubernetes API server
      {guest: 2379, host: 2379},     # etcd server client API
      {guest: 2380, host: 2380},     # etcd server client API
      {guest: 10250, host: 10250},   # Kubelet API
      {guest: 10259, host: 10259},   # kube-scheduler
      {guest: 10257, host: 10257},   # kube-controller-manager
      {guest: 8080, host: 8080},     # Common web services
      {guest: 30000, host: 30000},   # NodePort services range start
      {guest: 32767, host: 32767}    # NodePort services range end
    ]
  },
  "kube-node-1" => {
    ram: 1500, 
    cpus: 2,
    ip: '192.168.56.13',
    role: 'k8s_worker',
    host_port: 2724,
    additional_ports: [
      {guest: 10250, host: 10250},   # Kubelet API
      {guest: 30000, host: 30000},   # NodePort services range start
      {guest: 32767, host: 32767}    # NodePort services range end
    ]
  },
  "kube-node-2" => {
    ram: 1500, 
    cpus: 2,
    ip: '192.168.56.14',
    role: 'k8s_worker',
    host_port: 2725,
    additional_ports: [
      {guest: 10250, host: 10250},   # Kubelet API
      {guest: 30000, host: 30000},   # NodePort services range start
      {guest: 32767, host: 32767}    # NodePort services range end
    ]
  },
  "test-node-1" => {
    ram: 2568, 
    cpus: 2,
    ip: '192.168.56.18',
    role: 'flask_app',
    host_port: 27257,
    additional_ports: [
      {guest: 5000, host: 5000},     # Flask app
      {guest: 5432, host: 5432},     # PostgreSQL
      {guest: 8080, host: 8080},     # Alternative web port
      {guest: 3000, host: 3000}      # Frontend development
    ]
  }
}

Vagrant.configure("2") do |config|
  VM_STAT.each do |vm_name, info|
    config.vm.define vm_name do |node|
      # Basic VM configuration
      node.vm.box = info[:vm_image] || "ubuntu/jammy64"
      node.vm.hostname = vm_name
      
      # Generate or use existing SSH keys for this VM
      vm_ssh_dir = "#{SSH_KEYS_DIR}/#{vm_name}"
      vm_key = "#{vm_ssh_dir}/id_rsa"
      vm_key_pub = "#{vm_ssh_dir}/id_rsa.pub"

      # Create VM-specific SSH keys if they don't exist
      unless File.exist?(vm_key)
        FileUtils.mkdir_p(vm_ssh_dir)
        system("ssh-keygen -t rsa -b 4096 -f #{vm_key} -N '' -C '#{vm_name}'")
        puts "Generated new SSH key pair for #{vm_name}"
      end

      # SSH Configuration
      node.ssh.insert_key = false
      node.ssh.private_key_path = [vm_key]
      node.ssh.forward_agent = true

      # Network configuration
      node.vm.network "private_network", ip: info[:ip]
      
      # SSH port forwarding
      node.vm.network "forwarded_port", guest: 22, host: info[:host_port], id: "ssh"
      
      # Additional ports forwarding
      if info[:additional_ports]
        info[:additional_ports].each do |port_mapping|
          node.vm.network "forwarded_port", 
            guest: port_mapping[:guest], 
            host: port_mapping[:host],
            auto_correct: true
        end
      end

      # Initial SSH setup and security
      node.vm.provision "shell", inline: <<-SHELL
        # Secure SSH configuration
        sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        
        # Setup SSH directory
        mkdir -p /home/vagrant/.ssh
        chmod 700 /home/vagrant/.ssh
        > /home/vagrant/.ssh/authorized_keys
        
        # Add VM-specific key
        echo '#{File.read(vm_key_pub).strip}' > /home/vagrant/.ssh/authorized_keys
        
        # Add Ansible controller key for K8s nodes
        if [[ "#{info[:role]}" =~ ^k8s_ ]]; then
          echo '#{File.read("#{dir}/ansible-vm/tower/ansible.pub").strip}' >> /home/vagrant/.ssh/authorized_keys
        fi
        
        chmod 600 /home/vagrant/.ssh/authorized_keys
        chown -R vagrant:vagrant /home/vagrant/.ssh
        
        sudo systemctl restart sshd
      SHELL

      # Share application code for Flask app
      if info[:role] == 'flask_app'
        node.vm.synced_folder "./flask_book_store", "/vagrant/flask_book_store"
      end

      # K8s-specific setup
      if info[:role] == 'k8s_master'
        node.vm.provision "shell", inline: <<-SHELL
          mkdir -p /vagrant/.kube
          cp /etc/kubernetes/admin.conf /vagrant/.kube/config
          chmod 644 /vagrant/.kube/config
        SHELL
      end
      
      # Provider configuration
      node.vm.provider "virtualbox" do |vb|
        vb.memory = info[:ram]
        vb.cpus = info[:cpus]
        vb.name = vm_name
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
    end
  end
end