# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box     = 'dummy'
#  config.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'

  # Librarian-Chef is in use, add a reminder
  Vagrant.require_plugin 'vagrant-librarian-chef'
  Vagrant.require_plugin 'vagrant-omnibus'

  config.omnibus.chef_version = :latest

  # Initialize variables
  chef_cookbooks = []

  # Workaround for "sudo: sorry, you must have a tty to run sudo" error. See
  # https://github.com/mitchellh/vagrant/issues/1482 for details.
  config.ssh.pty = true

  config.vm.provider "virtualbox" do |v, override|
    v.memory = 1024
    override.vm :host_shell, inline: 'echo "Provider=virtualbox"'
  end

  ### RAX provider settings
  config.vm.provider :rackspace do |rs, override|
    # Overrides should be avoided, we have no choice here :(
    override.vm.box = 'dummy'
    override.vm.box_url = 'https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box'
    rs.username = ENV['OS_USERNAME']
    rs.api_key  = ENV['OS_API_KEY']
    rs.rackspace_region = ENV.fetch('OS_REGION_NAME', :lon).downcase.to_sym
    rs.public_key_path = File.expand_path("~/.ssh/id_rsa.pub")
    #rs.key_name = 
    override.ssh.username = 'root'
    override.ssh.private_key_path = ENV['VAGRANT_SSH_PRIVATE_KEY_PATH'] || "~/.ssh/id_rsa"
    rs.server_name = config.vm.hostname
    #rs.key_name = 'rax'
    rs.flavor   = /2 GB Performance/
    rs.image    = /CentOS 6.5/
    rs.disk_config = 'MANUAL'
#    rs.metadata = {
#      'expire-on' => (Date.today + 30).to_s
#    }
    override.vm :host_shell, inline: 'cat /etc/motd.tail'
    # Chef cookbooks needed for our execution
    chef_cookbooks = [ "rackspace::mount", "rackspace::motd" ]
  end

  config.vm.provider :aws do |aws, override|
    # Workaround for "~/aws/keys/#{aws.region}/#{ENV['USER']}.pem", which for
    # some reason expands to an object instead of a string. E.g. the following
    # fails:
    #
    #   override.ssh.private_key_path = ENV['VAGRANT_SSH_PRIVATE_KEY_PATH'] ||
    #                                   "~/aws/keys/#{aws.region}/#{ENV['USER']}.pem"
    #
    aws_region            = ENV['VAGRANT_AWS_REGION']        || 'eu-west-1'
    aws.region            = aws_region

    aws.keypair_name      = ENV['VAGRANT_AWS_KEYPAIR_NAME']  || ENV['USER']

    # See http://aws.amazon.com/ec2/instance-types/ for list of Amazon EC2
    # instance types.
    aws.instance_type     = ENV['VAGRANT_AWS_INSTANCE_TYPE'] || 'm1.medium'

    # Tag the EC2 instance for easier management and clean-up, especially on
    # shared accounts.
    aws.tags = {
      'Name'      => ENV['VAGRANT_AWS_TAG_NAME']   || 'MongoDB (started by vagrant-mongodb)',
      'owner'     => ENV['VAGRANT_AWS_TAG_OWNER']  || ENV['USER'],
      'expire-on' => ENV['VAGRANT_AWS_TAG_EXPIRE'] || (Date.today + 30).to_s
    }

    # See http://aws.amazon.com/ec2/instance-types/#instance-details for the
    # instance types that support this.
    aws.ebs_optimized     = false

    # TODO Auto-create the 'MongoDB' security group, or at least document
    # manual steps. Inbound ports on 22 (SSH) and 27017 (MongoDB) should be
    # allowed.
    aws.security_groups = [ 'MongoDB' ]

    # List of Amazon Linux AMIs (e.g. amzn-ami-pv-2013.09.2.x86_64-ebs).
    # Generated by tools/ami-ids/ami-ids.
    aws.region_config 'ap-northeast-1', :ami => 'ami-0d13700c'
    aws.region_config 'ap-southeast-1', :ami => 'ami-b4baeee6'
    aws.region_config 'ap-southeast-2', :ami => 'ami-5ba83761'
    aws.region_config 'eu-west-1',      :ami => 'ami-5256b825'
    aws.region_config 'sa-east-1',      :ami => 'ami-c99130d4'
    aws.region_config 'us-east-1',      :ami => 'ami-bba18dd2'
    aws.region_config 'us-west-1',      :ami => 'ami-a43909e1'
    aws.region_config 'us-west-2',      :ami => 'ami-ccf297fc'

    override.ssh.username         = 'ec2-user'
    override.ssh.private_key_path = ENV['VAGRANT_SSH_PRIVATE_KEY_PATH'] ||
                                    "~/aws/keys/#{aws_region}/#{ENV['USER']}.pem"
    chef_cookbooks = [ "ebs" ]
  end

  # See http://docs.mongodb.org/manual/administration/production-notes/ for
  # details.
  config.vm.provision :chef_solo do |chef|

    # Add any predefined cookbooks
    chef_cookbooks.each do |chef_cookbook|
        chef.add_recipe chef_cookbook
    end
    chef.add_recipe 'yum-epel'
    chef.add_recipe 'utils'
    chef.add_recipe 'mongodb::10gen_repo'
    chef.add_recipe 'mongodb'

    if ENV['VAGRANT_DEBUG']
      chef.log_level = :debug
    end

    chef.json = {
      :mongodb => {
        :dbpath     => '/data',
        :smallfiles => true      # Speed up initial journal preallocation
      },
      :ebs => {
        :access_key         => ENV['AWS_ACCESS_KEY'],
        :secret_key         => ENV['AWS_SECRET_KEY'],
        :fstype             => 'ext4',  # Or 'xfs'
        :no_boot_config     => true,
        :md_read_ahead      => 32,      # Size in number of 512B sectors (16KB)
        # :mdadm_chunk_size => 256,
      }
    }

    if ENV['VAGRANT_EBS_RAID']
      chef.json[:ebs][:raids] = {
        '/dev/md0' => {
          :num_disks     => 4,
          :disk_size     => 10,    # Size in GB
          :raid_level    => 10,
          :fstype        => chef.json[:ebs][:fstype],
          :mount_point   => '/data',
          :mount_options => 'noatime,noexec',
          # :piops       => 2000,  # Provisioned IOPS
          # :uselvm      => true
        }
      }
    else
      chef.json[:ebs][:volumes] = {
        '/data' => {
          :size          => 20,  # Size in GB
          :fstype        => chef.json[:ebs][:fstype],
          :mount_options => 'noatime,noexec'
        }
      }
    end
  end
end
