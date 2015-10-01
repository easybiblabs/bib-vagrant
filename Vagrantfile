Vagrant.require_plugin "bib-vagrant"

Vagrant.configure("2") do |config|
  foo = ::Bib::Vagrant::Config.new()
  puts foo.get.inspect
 
  # for testing ubuntu 14.04
  config.vm.box = 'trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'

  # for testing ubuntu 15.04
  # config.vm.box = 'vivid-server-cloudimg-amd64-vagrant-disk1.box'
  # config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/vivid/current/vivid-server-cloudimg-amd64-vagrant-disk1.box'	

  # config.vm.provision :shell, :path => 'apt-spy-2-bootstrap.sh'

  config.vm.provision 'shell', inline: 'sudo apt-get -y update'

  # for testing the latest greatest npm
  # config.vm.provision 'shell', inline: 'sudo apt-get -y install curl'
  # config.vm.provision 'shell', inline: 'curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -'

  config.vm.provision 'shell', inline: 'sudo apt-get -y install nodejs npm'

  config.vm.provision 'bib_configure_npm' 

  config.vm.provision 'shell', inline: 'npm config list'

  config.vm.provision 'shell', inline: 'npm --loglevel silly view test'

end
