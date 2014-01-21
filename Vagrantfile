
# @param swap_size_mb [Integer] swap size in megabytes
# @param swap_file [String] full path for swap file, default is /swapfile1
# @return [String] the script text for shell inline provisioning
def create_swap(swap_size_mb, swap_file = "/swapfile1")
  <<-EOS
    if [ ! -f /swapfile1 ]; then
      echo "Creating #{swap_size_mb}mb swap file=#{swap_file}. This could take a while..."
      dd if=/dev/zero of=#{swap_file} bs=1024 count=#{swap_size_mb * 1024}
      mkswap #{swap_file}
      chmod 0600 #{swap_file}
      swapon #{swap_file}
      echo "#{swap_file} swap swap defaults 0 0" >> /etc/fstab
    fi
  EOS
end

Vagrant.require_plugin "vagrant-berkshelf"
Vagrant.require_plugin "vagrant-omnibus"


Vagrant.configure("2") do |config|

  config.vm.define :storm do |storm|
    storm.vm.box = "precise64"
    storm.vm.host_name = "storm"

    # storm ui
    storm.vm.network :forwarded_port, :guest => 8080, :host => 8080

    # storm numbus thrift
    storm.vm.network :forwarded_port, :guest => 6627, :host => 6627

    storm.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 1536]
    end

    storm.vm.provision :shell, :inline => create_swap(512)


    storm.vm.provision :chef_solo do |chef|
      chef.log_level = :debug

      chef.cookbooks_path = ["./cookbooks"]
      chef.data_bags_path = ["./databags"]

      chef.add_recipe "apt"
      chef.add_recipe "users::sysadmins" # setup users (from data_bags/users/*.json)
      # chef.add_recipe "users::sysadmin_sudo" # adds %sysadmin group to sudoers
      chef.add_recipe "java"
      chef.add_recipe "storm::singlenode"
      chef.add_recipe "python"


      chef.json = {
        :java => {
          :oracle => {
            "accept_oracle_download_terms" => true
          },
          :install_flavor => "openjdk",
          :jdk_version => "7",
        },

        :storm => {
          :deploy => {
            :user => "storm",
            :group => "storm",
          },
          :nimbus => {
            :host => "localhost",
            :childopts => "-Xmx128m",
          },
          :supervisor => {
            :hosts =>  ["localhost"],
            :childopts => "-Xmx128m",
          },
          :worker => {
            :childopts => "-Xmx128m",
          },
          :ui => {
            :childopts => "-Xmx128m",
          },
        },
      }
    end

  end

  # vagrant-omnibus plugin: auto install/upgrate chef
  config.omnibus.chef_version = "10.18.2"
end
