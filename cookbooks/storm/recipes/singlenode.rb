include_recipe "storm"

template "Storm conf file" do
  path "/home/#{node[:storm][:deploy][:user]}/storm-#{node[:storm][:version]}/conf/storm.yaml"
  source "singlenode.yaml.erb"
  owner node[:storm][:deploy][:user]
  group node[:storm][:deploy][:group]
  mode 0644
end

bash "Start nimbus" do
  user node[:storm][:deploy][:user]
  cwd "/home/#{node[:storm][:deploy][:user]}"
  code <<-EOH
  pid=$(pgrep -f backtype.storm.daemon.nimbus)
  if [ -z $pid ]; then
    nohup storm-#{node[:storm][:version]}/bin/storm nimbus >>nimbus.log 2>&1 &
  fi
  EOH
end

bash "Start supervisor" do
  user node[:storm][:deploy][:user]
  cwd "/home/#{node[:storm][:deploy][:user]}"
  code <<-EOH
  pid=$(pgrep -f backtype.storm.daemon.supervisor)
  if [ -z $pid ]; then
    nohup storm-#{node[:storm][:version]}/bin/storm supervisor >>supervisor.log 2>&1 &
  fi
  EOH
end

bash "Start ui" do
  user node[:storm][:deploy][:user]
  cwd "/home/#{node[:storm][:deploy][:user]}"
  code <<-EOH
  pid=$(pgrep -f backtype.storm.ui.core)
  if [ -z $pid ]; then
    nohup storm-#{node[:storm][:version]}/bin/storm ui >>ui.log 2>&1 &
  fi
  EOH
end
