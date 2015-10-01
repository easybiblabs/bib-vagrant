Vagrant.require_plugin "bib-vagrant"

Vagrant.configure("2") do |config|
  foo = ::Bib::Vagrant::Config.new()
  puts foo.get.inspect
 
  ##config.vm.box = 'trusty-server-cloudimg-amd64-vagrant-disk1.box'
  ## config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'

  config.vm.box = 'vivid-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/vivid/current/vivid-server-cloudimg-amd64-vagrant-disk1.box'	

  # config.vm.provision :shell, :path => 'apt-spy-2-bootstrap.sh'

  config.vm.provision 'shell', inline: 'sudo apt-get -y update'
  config.vm.provision 'shell', inline: 'sudo apt-get -y install curl'
  config.vm.provision 'shell', inline: 'curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -'
  config.vm.provision 'shell', inline: 'sudo apt-get -y install nodejs'

  config.vm.provision 'bib_configure_npm' 

  config.vm.provision 'shell', inline: 'npm config list'

  config.vm.provision 'shell', inline: 'npm -ddd view npm'

end
