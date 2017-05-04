version = node["redis-sentinel"]["version"]

if File.exists? node["redis-sentinel"]["redis_server_path"]
  installed_version = `/usr/local/bin/redis-server -v`[/(\d\.\d\.\d)/]
end

if installed_version.nil? || version > installed_version
  remote_file "#{Chef::Config[:file_cache_path]}/redis-#{version}.tar.gz" do
    source "http://download.redis.io/releases/redis-#{version}.tar.gz"
    mode "0755"
  end
  bash "build-and-install-redis" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
      tar -xvzf redis-#{version}.tar.gz
      cd redis-#{version}
      (cd deps && make hiredis lua jemalloc linenoise && make geohash-int)
      make && make install
    EOF
  end
end

# Support Opsworks
master_ip = node["redis-sentinel"]["master_ip"]


if master_ip.nil? || master_ip.empty?
  master_instance = search(:aws_opsworks_instance, "hostname:#{node["redis-sentinel"]["master_hostname"]}").first
  master_ip = master_instance["ipaddress"]
end

%w(/var/run/redis/ /var/lib/redis/ /var/log/redis/ /etc/redis).each do |dir|
  directory dir
end

priority = ( node["hostname"][-1].to_i + 1 ) * 10

Chef::Log.info("Redis Master: #{master_ip}")

template "/etc/redis/redis.conf" do
  source "redis.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables ({
    master_ip: master_ip,
    master_port: node["redis-sentinel"]["master_port"],
    priority: priority
  })
  notifies :restart, "service[redis_6379]", :delayed
end

template "/etc/init.d/redis_6379" do
  source "redis.init.erb"
  owner "root"
  group "root"
  mode 0755
end

service "redis_6379" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end
