Vagrant.configure(2) do |config|

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.box = "boxcutter/centos68"

  config.vm.provision "shell" do |s|
    s.inline = "yum install epel-release -y && yum update -y && yum install htop vim -y"
  end

  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = "cookbooks/redis-sentinel/Berksfile"

  config.vm.provision "chef_solo" do |chef|
    chef.log_level = :info
    chef.json = {
      "redis-sentinel" => {
        "master_ip" => "192.168.77.10"
      }
    }
    chef.add_recipe "build-essential"
    chef.add_recipe "redis-sentinel"
  end

  config.vm.define "redis-master", primary: true do |master|
    master.vm.network "private_network", ip: "192.168.77.10"
    master.vm.hostname = "redis-master"
  end

  (1..2).each do |i|
    config.vm.define "redis-slave#{i}" do |slave|
      slave.vm.network "private_network", ip: "192.168.77.1#{i}"
      slave.vm.hostname = "redis-slave#{i}"
    end
  end

end
