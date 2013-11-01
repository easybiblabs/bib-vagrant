require 'bib/vagrant/config'

class ConfigTest < Minitest::Test

  @@fixture_dir = nil

  def setup
    @@fixture_dir = File.dirname(__FILE__) + "/fixtures"

    FileUtils.mkdir @@fixture_dir
  end

  def teardown
    FileUtils.rm_rf @@fixture_dir if File.exists?(@@fixture_dir)
  end

  def test_config

    c = Bib::Vagrant::Config.new(@@fixture_dir, false)
    assert_equal(false, c.has?)

    vagrant_config = c.get

    assert(File.exists?("#{@@fixture_dir}/.config/easybib/vagrantdefault.yml"))
    assert_kind_of(Hash, vagrant_config)

    assert_equal(false, vagrant_config["nfs"])
    assert_equal("~/Sites/easybib/cookbooks", vagrant_config["cookbook_path"])
    assert_equal("debug", vagrant_config["chef_log_level"])
    assert_equal("{}", vagrant_config["additional_json"])
    assert_equal(false, vagrant_config["gui"])

  end

  # I wish I knew how to write a data provider with minitest
  def test_validate!
    config = {
      "nfs" => "yes",
      "gui" => false,
      "cookbook_path" => "/this/does/not/exist",
      "chef_log_level" => "debug",
      "additional_json" => ""
    }

    c = Bib::Vagrant::Config.new(@@fixture_dir, false)
    vagrant_config = c.get

    assert_raises(RuntimeError) {
      c.validate!(config)
    }

    config["nfs"] = false
    config["cookbook_path"] = '~/'

    assert(c.validate!(config))

    config["additional_json"] = "{'hello'}"

    assert_raises(RuntimeError) {
      c.validate!(config)
    }

  end

end
