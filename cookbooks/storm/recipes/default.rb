#
# Cookbook Name:: storm-project
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w[ curl unzip build-essential pkg-config libtool autoconf git-core uuid-dev python-dev zookeeper ].each do |pkg|
    package pkg do
        retries 2
        action :install
    end
end

bash "Setup zookeeper as a daemon" do
  code <<-EOH
  sudo ln -s /usr/share/zookeeper/bin/zkServer.sh /etc/init.d/zookeeper
  EOH
  not_if do
    ::File.exists?("/etc/init.d/zookeeper")
  end
end

service "zookeeper" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

bash "Install zeromq 2.1.7" do
  code <<-EOH
  cd /tmp
  curl -O http://download.zeromq.org/zeromq-2.1.7.tar.gz
  tar -xzvf zeromq-2.1.7.tar.gz
  cd zeromq-2.1.7
  ./configure
  make
  make install
  EOH
  not_if do
    ::File.exists?("/usr/local/lib/libzmq.so")
  end
end

bash "Install jzmq" do
  code <<-EOH
  export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64
  cd /tmp
  rm -rf jzmq || true
git clone --depth 1 https://github.com/nathanmarz/jzmq.git
cd jzmq
./autogen.sh
./configure
touch src/classdist_noinst.stamp
cd src/
CLASSPATH=.:./.:$CLASSPATH javac -d . org/zeromq/ZMQ.java org/zeromq/App.java org/zeromq/ZMQForwarder.java org/zeromq/EmbeddedLibraryTools.java org/zeromq/ZMQQueue.java org/zeromq/ZMQStreamer.java org/zeromq/ZMQException.java
cd ..
make
sudo make install
  EOH
  not_if do
    ::File.exists?("/usr/local/lib/libjzmq.so")
  end
end

bash "Storm install" do
  user node[:storm][:deploy][:user]
  cwd "/home/#{node[:storm][:deploy][:user]}"
  code <<-EOH
  mkdir mnt-storm || true
  wget https://dl.dropbox.com/u/133901206/storm-#{node[:storm][:version]}.zip
  unzip storm-#{node[:storm][:version]}.zip
  cd storm-#{node[:storm][:version]}
  EOH
  not_if do
    ::File.exists?("/home/#{node[:storm][:deploy][:user]}/storm-#{node[:storm][:version]}")
  end
end
