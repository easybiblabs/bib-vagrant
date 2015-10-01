Vagrant.require_plugin "bib-vagrant"

Vagrant.configure("2") do |config|
  foo = ::Bib::Vagrant::Config.new()
  puts foo.get.inspect
 
  config.vm.box = 'trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'

  config.vm.provision 'shell', inline: 'apt-get -y update && apt-get -y install node npm'

  config.vm.provision 'bib_configure_npm' 

  config.vm.provision 'shell', inline: 'npm config list'

  config.vm.provision 'shell', inline: 'npm -ddd view npm'

end
