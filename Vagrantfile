Vagrant.configure(2) do |config|
  config.vm.synced_folder './shared', '/home/vagrant/shared',
                          create: true, owner: 'vagrant', group: 'vagrant'
  config.vm.synced_folder './ansible', '/home/vagrant/ansible',
                          create: true, owner: 'vagrant', group: 'vagrant'

  # BGP Router
  config.vm.define 'rt-01' do |node|
    node.vm.provider 'virtualbox' do |vb|
      vb.customize ['modifyvm', :id, '--ostype', 'Debian_64']
      vb.cpus = 1
      vb.memory = 512
      vb.gui = false
    end
    node.vm.hostname = 'rt-01'
    node.vm.box = 'higebu/vyos'
    # eth1
    node.vm.network 'private_network',
                    ip: '172.17.0.1', netmask: '255.255.255.0', auto_config: true,
                    virtualbox__intnet: 'k8s-cluster'
    # eth2
    node.vm.network 'private_network',
                    ip: '172.17.1.1', netmask: '255.255.255.0', auto_config: true,
                    virtualbox__intnet: 'client'
  end

  # client-01
  config.vm.define 'client-01' do |node|
    node.vm.provider 'virtualbox' do |vb|
      vb.cpus = 1
      vb.memory = 512
      vb.gui = false
    end
    node.vm.hostname = 'client-01'
    node.vm.box = 'ubuntu/cosmic64'
    # enp0s8
    node.vm.network 'private_network',
                    ip: '172.17.1.10', netmask: '255.255.255.0', auto_config: true,
                    virtualbox__intnet: 'client'
    node.vm.provision :ansible_local do |ansible|
      ansible.compatibility_mode = '2.0'
      ansible.playbook = '/home/vagrant/ansible/all.yml'
      ansible.inventory_path = '/home/vagrant/ansible/inventories/clients'
      ansible.limit = 'clients'
    end
  end

  # k8s-master-01
  config.vm.define 'k8s-master-01' do |node|
    node.vm.provider 'virtualbox' do |vb|
      vb.cpus = 1
      vb.memory = 2048
      vb.gui = false
    end
    node.vm.hostname = 'k8s-master-01'
    node.vm.box = 'ubuntu/cosmic64'
    # enp0s8
    node.vm.network 'private_network',
                    ip: '172.17.0.10', netmask: '255.255.255.0', auto_config: true,
                    virtualbox__intnet: 'k8s-cluster'
    node.vm.provision :ansible_local do |ansible|
      ansible.compatibility_mode = '2.0'
      ansible.playbook = '/home/vagrant/ansible/all.yml'
      ansible.inventory_path = '/home/vagrant/ansible/inventories/masters'
      ansible.limit = 'masters'
    end
  end

  # k8s-nodes
  (1..3).each do |i|
    hostname = 'k8s-node-%s' % (i.to_s.rjust(2,'0'))
    config.vm.define hostname do |node|
      node.vm.provider 'virtualbox' do |vb|
        vb.cpus = 1
        vb.memory = 1024
        vb.gui = false
      end
      node.vm.hostname = hostname
      node.vm.box = 'ubuntu/cosmic64'
      node.vm.network 'private_network',
                      ip: '172.17.0.%s' % ( i + 20 ), netmask: '255.255.255.0', auto_config: true,
                      virtualbox__intnet: 'k8s-cluster'
      node.vm.provision :ansible_local do |ansible|
        ansible.compatibility_mode = '2.0'
        ansible.playbook = '/home/vagrant/ansible/all.yml'
        ansible.inventory_path = '/home/vagrant/ansible/inventories/nodes'
        ansible.limit = 'nodes'
      end
    end
  end
end
