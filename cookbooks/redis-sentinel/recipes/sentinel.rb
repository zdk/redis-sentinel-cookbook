
service "redis-sentinel" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :nothing
end

template "/etc/redis/sentinel.conf" do
  source "sentinel.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/init.d/redis-sentinel" do
  source "sentinel.init.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :enable, "service[redis-sentinel]", :immediately
end

execute "/etc/init.d/redis-sentinel start"
