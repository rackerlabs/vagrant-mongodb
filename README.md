# vagrant-mongodb

This project is based on [MongoDB EC2](https://github.com/jamestyj/vagrant-mongodb)
The goal of this project is to simplify the creation of MongoDB instances for
testing and development. It relies on [Rackspace Public Cloud Servers](http://www.rackspace.com/cloud/),
 [VirtualBox](http://www.virtualbox.org/) or [Amazon EC2](http://aws.amazon.com/ec2/).

Once the instance is up and running, [Chef](http://www.opscode.com/chef/) takes
over to set things up.

## 1  Quickstart

Once you have the initial configuration done (details in later sections),
spinning up a new fully configured MongoDB instance in  from scratch takes
about 5 mins.

  * To start an instance with the defaults, just run `./up` (script '[up]
    (up)').  This starts a new instance, installs, configures, and then SSHs
    into it. It does the following by default:

    * If you want to use different providers rathern than `./up` use `vagrant up --provider=rackspace` for
    rackspace, `vagrant up --provider=virtualbox` for VirtualBox or `vagrant up --provider=aws` for Amazon EC2

    * Starts a new Cloud Performance Server running CentOS 6.5.

    * Mounts the allocated data disk and mounts it on `/data` with `noatime,noexec`.

    * The latest stable version of MongoDB is installed from the MongoDB, Inc.
      (formerly 10gen) repositories. It is configured with `dbpath=/data` and
      `smallfiles=true` (to speed up initial journal preallocation).

    * Performance monitoring tools `htop`, `dstat`, and `sysstat` (which
      provides `iostat`) are installed. The [MongoDB plugin for dstat]
      (https://github.com/gianpaj/dstat) is also installed.

    * Productivity tools like [MongoHacker]
      (https://github.com/TylerBrock/mongo-hacker), [tmux]
      (http://tmux.sourceforge.net/), and [Mosh] (http://mosh.mit.edu/) are
      also installed.

  * Once you're done, run `./down` (script '[down] (down)') to terminate the
    instance. Note that you'll need to remove the EBS volumes on your own.


## 2  Configuration

### 2.1  Initial setup

  1. [Download and install Vagrant](http://www.vagrantup.com/downloads). Use
     the latest stable release (e.g. version 1.4 and above).

  1. Install the required Vagrant plugins by running:

     ```bash
     vagrant plugin install vagrant-aws
     vagrant plugin install vagrant-rackspace
     vagrant plugin install vagrant-librarian-chef
     vagrant plugin install vagrant-omnibus
     ```

  1. Install [Librarian Chef](https://github.com/applicationsonline/librarian-chef). If you already have Ruby
     installed (which you should), simply run:

     ```bash
     sudo gem install librarian-chef
     ```

### 2.1.1  Rackspace Public Cloud

  1. Import your Rackspace Public Cloud credentials, you can add them to your environment if you wish.

    ```bash
    # This is your cloud account username
    export OS_USERNAME=mycloudaccount
    # This is your cloud account tenant number, next to your username on mycloud.rackspace.com
    export OS_TENANT_NAME=10012345
    export OS_PROJECT_ID=10012345
    # This is your cloud account API KEY, available on mycloud.rackspace.com
    export OS_PASSWORD=5e0c5f31346342903c8484fd9aa3u890
    export OS_API_KEY=5e0c5f31346342903c8484fd9aa3u890
    # This is your AUTH endpoint
    # For London it is https://lon.identity.api.rackspacecloud.com/v2.0/
    # For all other regions it is https://identity.api.rackspacecloud.com/v2.0/
    export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
    # This is your AUTH system
    # For London it is rackspace_uk
    # For all other regions it is rackspace
    export OS_AUTH_SYSTEM=rackspace
    # This is your OS REGION NAME
    # LON => London
    # IAD => Virginia
    # ORD => Dallas
    # HKG => Hong Kong
    # SYD => Sydney
    export OS_REGION_NAME=IAD
    export NOVA_RACK_AUTH=1
    export OS_NO_CACHE=1

    ```

  1. Export your SSH credentials, by default it'll look for `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
    ```bash
    export VAGRANT_SSH_PUBLIC_KEY_PATH=~/.ssh/id_dsa.pub
    export VAGRANT_SSH_PRIVATE_KEY_PATH=~/.ssh/id_dsa
    ```

### 2.1.2 VirtualBox

  1. Nothing to prepare here, enjoy! :)

### 2.1.3  Amazon EC2

  1. Add your AWS access and secret keys as environment variables by adding the
     following to your `~/.bash_profile` or `~/.bashrc`. If you've used the AWS
     command line tools before, this should already be there.

     ```bash
     export AWS_ACCESS_KEY=ABCDEFGHIJKLMNOPQRST
     export AWS_SECRET_KEY=1234567890abcedefgijklmnopqrstuvwxyzABCD
     ```

  1. The script expects your AWS EC2 keypair private key to be in the following
     location: `~/aws/keys/#{aws.region}/#{ENV['USER']}.pem`. For example, if
     your local login user is `jamestyj` and you're using the default EC2
     region `eu-west-1`, it will use the private key at
     `~/aws/keys/eu-west-1/jamestyj.pem`. You can override this with the
     environment variable `VAGRANT_SSH_PRIVATE_KEY_PATH`.

  1. Create an EC2 security group (firewall rule) named 'MongoDB'. It must
     allow incoming traffic on TCP ports 22 (SSH) and 27017 (MongoDB). We also
     recommend opening UDP ports 60000 to 60010 for Mosh (SSH replacement).

  1. You can also modify the following Environment Variables

     ```bash
     # Amazon EC2 region where the machine will be created
     export VAGRANT_AWS_REGION=eu-west-1
     # Name of my Amazon EC2 keypair
     export VAGRANT_AWS_KEYPAIR_NAME=mykeypair
     # Size of my Amazon EC2 instance
     export VAGRANT_AWS_INSTANCE_TYPE=m1.medium
     # Location of my Amazon EC2 private cloud
     export VAGRANT_SSH_PRIVATE_KEY_PATH=~/.ec2/privatekey.pem
     # Raid level for EBS volumes
     export VAGRANT_EBS_RAID=10
     # Tag for Amazon EC2 instance
     export VAGRANT_AWS_TAG_NAME=TagName
     # Owner for Amazon EC2 instance
     export AMAZON_TAG_OWNER=Owner
     # Expire-On Tag for Amazon EC2 instance
     export VAGRANT_AWS_TAG_EXPIRE=YYYY-MM-DD
     ```

### 2.2  Vagrant config

#### 2.2.1 Environment variables

1. There are a number of commonly used options that can be altered via environment
variables. You can refer to the Vagrant configuration file ([Vagrantfile]
(Vagrantfile)) for details. Here's a list of available environment variables:

  1. `VAGRANT_DEBUG` - Set Chef log level to `:debug`. Defaults to false
     (`:info`).

#### 2.2.2 Modifying the Vagrant config file

Modifying [Vagrantfile] (Vagrantfile) directly gives you more control over your
instance. Details can be found in the Vagrant documentation, but here are some
interesting ones:

  1. `config.vm.provider :rackspace` section.

     This section contains all the Rackspace specific configuration, which you can
     modify accordingly to suit your needs and preferences.

  1. `config.vm.provider :virtualbox` section.

     This section contains all the VirtualBox specific configuration, which you can
     modify accordingly to suit your needs and preferences.

  1. `config.vm.provider :aws` section.

     This section contains all the AWS specific configuration, which you can
     modify accordingly to suit your needs and preferences. In particular, you
     may want to add the AMI ID of the Amazon Linux AMI (latest 64 bit, EBS
     backed) for your region if it's not already there. Other than that,
     there's probably not much else you want to change here.

  1. `config.vm.provision :chef_solo` section.

     This section contains all the Chef (Solo) configuration used to setup the
     EC2 instance from the plain Amazon Linux state. It installs a number of
     utilities and tools (from the `utils` and `mosh` cookbooks/recipes), as
     well has handling the EBS volume configuration and MongoDB installation
     plus configuration.

     Most of the interesting options are under the `chef.json` JSON
     configuration, in particular the MongoDB specific ones eg.:

     ```ruby
     :mongodb => {
       :dbpath     => '/data',
       :smallfiles => true      # For faster initial journal preallocation
     }
     ```

     And EBS specific ones:

     ```ruby
     :ebs => {
       ...,
       :fstype           => 'ext4',
       :md_read_ahead    => 32,  # 16KB
       :mdadm_chunk_size => 256
     }
     ```

     As well as the EBS RAID, with provisioned IOPS (`piops`) and LVM disabled
     by default:

     ```ruby
     '/dev/md0' => {
       :num_disks     => 4,
       :disk_size     => 10,                # Size in GB
       :raid_level    => 10,
       :mount_point   => '/data',
       :mount_options => 'noatime,noexec',
       # :piops       => 2000,              # Provisioned IOPS
       # :uselvm      => true
     }
     ```

    You can add more recipes by appending `chef.add_recipe 'xxx'` statements
    and modifying `Berksfile` accordingly.

     Refer to the Chef EBS cookbook documentation for more details and options.


### 2.3  Chef config

We use Chef Solo to setup and configure the EC2 instance from scratch. This
allows full flexibility and transparency at the expense of spin up time, which
typically takes about 5 minutes so isn't really a problem.

#### 2.3.1 Cheffile

Librarian Chef is used to manage Chef cookbooks and dependencies. See [Cheffile]
(Cheffile) for the list of Chef cookbooks that are pulled from the OpsCode
cookbooks repository, or directly from the specified Git repositories.

Note that everything under `cookbooks/` will be removed and replaced with the
specified cookbooks.

#### 2.3.2 Chef cookbooks and recipes

The [my_cookbooks] (my_cookbooks/) directory contains cookbooks (eg. utils)
that are specific to this project, so we keep them in this Git tree to keep
things simple. Will likely split this out to a separate Git repository in
future.


## 3  Known issues

  1. The Amazon EBS volumes are not deleted when the EC2 instance is
     terminated, so you'll need to do this manually. The enhancement request is
     tracked in [Github Issues]
     (https://github.com/jamestyj/vagrant-mongodb/issues/1).

## 4 Contributions and feedback

Code and documentation contributions in the form of pull requests are very
welcomed! Please file feature requests and bugs reports via Github Issues.

## 5  Sample run output

```
$ vagrant up --provider=rackspace
Bringing machine 'default' up with 'rackspace' provider...
==> default: Installing Chef cookbooks with Librarian-Chef...
==> default: Finding flavor for server...
==> default: Finding image for server...
==> default: Launching a server with the following settings...
==> default:  -- Flavor: 2 GB Performance
==> default:  -- Image: CentOS 6.5 (PVHVM)
==> default:  -- Disk Config: MANUAL
==> default:  -- Name: mongodb-VUAFZBPL
==> default: Waiting for the server to be built...
==> default: Waiting for SSH to become available...
==> default: The server is ready!
==> default: Rsyncing folder: /Volumes/Code/rax/vagrant-mongodb/ => /vagrant
==> default: Rsyncing folder: /Volumes/Code/rax/vagrant-mongodb/cookbooks/ => /tmp/vagrant-chef-1/chef-solo-1/cookbooks
==> default: Installing Ohai plugin
==> default: Installing Chef 11.10.4 Omnibus package...
==> default: export TERM=vt100
==> default: sh install.sh -v 11.10.4 2>&1
==> default: exit
==> default: sh-4.1# export TERM=vt100
==> default: sh-4.1# sh install.sh -
==> default: v 11.10.4 2>&1
==> default: Downloading Chef 11.10.4 for el...
==> default: downloading https://www.getchef.com/chef/metadata?v=11.10.4&prerelease=false&p=el&pv=6&m=x86_64
==> default:   to file /tmp/install.sh.1806/metadata.txt
==> default: trying wget...
==> default: url    https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-11.10.4-1.el6.x86_64.rpm
==> default: md5    3fe6dd8e19301b6c66032496a89097db
==> default: sha256 edd5d2bcc174f67e5e5136fd7e5fffd9414c5f4949c68b28055b124185904d9f
==> default: downloaded metadata file looks valid...
==> default: downloading https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-11.10.4-1.el6.x86_64.rpm
==> default:   to file /tmp/install.sh.1806/chef-11.10.4-1.el6.x86_64.rpm
==> default: trying wget...
==> default: Checksum compare with sha256sum succeeded.
==> default: Installing Chef 11.10.4
==> default: installing with rpm...
==> default: warning: /tmp/install.sh.1806/chef-11.10.4-1.el6.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
==> default: Preparing...
==> default: ########################################    (100%)
==> defa########################################### [100%]
==> default:    1:chef
==> default:                                             (  1%)
==> default: #                                           (  3%)
==> default: ##                                          (  6%)
==> default: ###                                         (  8%)
==> default: ####                                        ( 10%)
==> default: #####                                       ( 13%)
==> default: ######                                      ( 15%)
==> default: #######                                     ( 17%)
==> default: ########                                    ( 19%)
==> default: #########                                   ( 22%)
==> default: ##########                                  ( 24%)
==> default: ###########                                 ( 26%)
==> default: ############                                ( 28%)
==> default: #############                               ( 31%)
==> default: ##############                              ( 33%)
==> default: ###############                             ( 35%)
==> default: ################                            ( 38%)
==> default: #################                           ( 40%)
==> default: ##################                          ( 42%)
==> default: ###################                         ( 44%)
==> default: ####################                        ( 47%)
==> default: #####################                       ( 49%)
==> default: ######################                      ( 51%)
==> default: #######################                     ( 53%)
==> default: ########################                    ( 56%)
==> default: #########################                   ( 58%)
==> default: ##########################                  ( 60%)
==> default: ###########################                 ( 63%)
==> default: ############################                ( 65%)
==> default: #############################               ( 67%)
==> default: ##############################              ( 69%)
==> default: ###############################             ( 72%)
==> default: ################################            ( 74%)
==> default: #################################           ( 76%)
==> default: ##################################          ( 78%)
==> default: ###################################         ( 81%)
==> default: ####################################        ( 83%)
==> default: #####################################       ( 85%)
==> default: ######################################      ( 88%)
==> default: #######################################     ( 90%)
==> default: ########################################    ( 92%)
==> default: #########################################   ( 94%)
==> default: ##########################################  ( 97%)
==> default: ########################################### [100%]
==> default: Thank you for installing Chef!
==> default: sh-4.1# exit
==> default: exit
==> default: Running provisioner: chef_solo...
Generating chef JSON and uploading...
Running chef-solo...
export TERM=vt100
chef-solo -c /tmp/vagrant-chef-1/solo.rb -j /tmp/vagrant-chef-1/dna.json
exit
[root@mongodb-vuafzbpl ~]# export TERM=vt100
ant-chef-1/dna.json pl ~]# chef-solo -c /tmp/vagrant-chef-1/solo.rb -j /tmp/vagr
[2014-03-17T16:26:47+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.10.4
[2014-03-17T16:26:47+00:00] INFO: *** Chef 11.10.4 ***
[2014-03-17T16:26:47+00:00] INFO: Chef-client pid: 2081
[2014-03-17T16:26:47+00:00] INFO: Setting the run_list to ["recipe[rackspace::motd]", "recipe[rackspace::partition]", "recipe[yum-epel]", "recipe[utils]", "recipe[mongodb::10gen_repo]", "recipe[mongodb]"] from JSON
[2014-03-17T16:26:47+00:00] INFO: Run List is [recipe[rackspace::motd], recipe[rackspace::partition], recipe[yum-epel], recipe[utils], recipe[mongodb::10gen_repo], recipe[mongodb]]
[2014-03-17T16:26:47+00:00] INFO: Run List expands to [rackspace::motd, rackspace::partition, yum-epel, utils, mongodb::10gen_repo, mongodb]
[2014-03-17T16:26:47+00:00] INFO: Starting Chef Run for mongodb-vuafzbpl
[2014-03-17T16:26:47+00:00] INFO: Running start handlers
[2014-03-17T16:26:47+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
[2014-03-17T16:26:47+00:00] WARN: CentOS doesn't provide mongodb, forcing use of 10gen repo
[2014-03-17T16:26:47+00:00] WARN: Cloning resource attributes for template[/etc/mongodb.conf] from prior resource (CHEF-3694)
[2014-03-17T16:26:47+00:00] WARN: Previous template[/etc/mongodb.conf]: /tmp/vagrant-chef-1/chef-solo-1/cookbooks/mongodb/recipes/install.rb:21:in `from_file'
[2014-03-17T16:26:47+00:00] WARN: Current  template[/etc/mongodb.conf]: /tmp/vagrant-chef-1/chef-solo-1/cookbooks/mongodb/definitions/mongodb.rb:137:in `block in from_file'
[2014-03-17T16:26:47+00:00] WARN: Cloning resource attributes for directory[/data] from prior resource (CHEF-3694)
[2014-03-17T16:26:47+00:00] WARN: Previous directory[/data]: /tmp/vagrant-chef-1/chef-solo-1/cookbooks/rackspace/recipes/partition.rb:3:in `from_file'
[2014-03-17T16:26:47+00:00] WARN: Current  directory[/data]: /tmp/vagrant-chef-1/chef-solo-1/cookbooks/mongodb/definitions/mongodb.rb:160:in `block in from_file'
[2014-03-17T16:26:47+00:00] WARN: Cloning resource attributes for template[/etc/init.d/mongod] from prior resource (CHEF-3694)
[2014-03-17T16:26:47+00:00] WARN: Previous template[/etc/init.d/mongod]: /tmp/vagrant-chef-1/chef-solo-1/cookbooks/mongodb/recipes/install.rb:42:in `from_file'
[2014-03-17T16:26:47+00:00] WARN: Current  template[/etc/init.d/mongod]: /tmp/vagrant-chef-1/chef-solo-1/cookbooks/mongodb/definitions/mongodb.rb:170:in `block in from_file'
Converging 26 resources
Recipe: rackspace::motd
  * cookbook_file[motd] action create[2014-03-17T16:26:47+00:00] INFO: cookbook_file[motd] backed up to /var/chef/backup/etc/motd.chef-20140317162647.967950
[2014-03-17T16:26:47+00:00] INFO: cookbook_file[motd] updated file contents /etc/motd

    - update content in file /etc/motd from e3b0c4 to 9e5ac4
        --- /etc/motd   2010-01-12 13:28:22.000000000 +0000
        +++ /tmp/.motd20140317-2081-1ebn3hs 2014-03-17 16:26:47.000000000 +0000
        @@ -1 +1,9 @@
        +
        + ____            _
        +|  _ \ __ _  ___| | _____ _ __   __ _  ___ ___
        +| |_) / _` |/ __| |/ / __| '_ \ / _` |/ __/ _ \    Rackspace
        +|  _ < (_| | (__|   <\__ \ |_) | (_| | (_|  __/      Performance Cloud Servers
        +|_| \_\__,_|\___|_|\_\___/ .__/ \__,_|\___\___|
        +                         |_|
        +[2014-03-17T16:26:47+00:00] INFO: cookbook_file[motd] mode changed to 444

    - change mode from '0644' to '0444'

Recipe: rackspace::partition
  * directory[/data] action create[2014-03-17T16:26:48+00:00] INFO: directory[/data] created directory /data

    - create new directory /data[2014-03-17T16:26:48+00:00] INFO: directory[/data] owner changed to 0
[2014-03-17T16:26:48+00:00] INFO: directory[/data] group changed to 0
[2014-03-17T16:26:48+00:00] INFO: directory[/data] mode changed to 755

    - change mode from '' to '0755'
    - change owner from '' to 'root'
    - change group from '' to 'root'

  * execute[format_data_disk] action runFilesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1310720 inodes, 5242879 blocks
262143 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=4294967296
160 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
    32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
    4096000

Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 23 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.
[2014-03-17T16:26:54+00:00] INFO: execute[format_data_disk] ran successfully

    - execute mkfs.ext4 /dev/xvde1

  * mount[data] action mount[2014-03-17T16:26:54+00:00] INFO: mount[data] mounted

    - mount /dev/xvde1 to data

  * mount[data] action enable[2014-03-17T16:26:54+00:00] INFO: mount[data] enabled

    - remount /dev/xvde1

Recipe: yum-epel::default
  * yum_repository[epel] action createRecipe: <Dynamically Defined Resource>
  * template[/etc/yum.repos.d/epel.repo] action create[2014-03-17T16:26:54+00:00] INFO: template[/etc/yum.repos.d/epel.repo] backed up to /var/chef/backup/etc/yum.repos.d/epel.repo.chef-20140317162654.542375
[2014-03-17T16:26:54+00:00] INFO: template[/etc/yum.repos.d/epel.repo] updated file contents /etc/yum.repos.d/epel.repo

    - update content in file /etc/yum.repos.d/epel.repo from 3e87de to 759e91
        --- /etc/yum.repos.d/epel.repo  2014-02-25 00:10:40.000000000 +0000
        +++ /tmp/chef-rendered-template20140317-2081-lgn4pu 2014-03-17 16:26:54.000000000 +0000
        @@ -1,27 +1,12 @@
        +# This file was generated by Chef
        +# Do NOT modify this file by hand.
        +
         [epel]
         name=Extra Packages for Enterprise Linux 6 - $basearch
        -baseurl=http://mirror.rackspace.com/epel/6/x86_64/
        -#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
        -failovermethod=priority
         enabled=1
        -gpgcheck=1
        -gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
        -
        -[epel-debuginfo]
        -name=Extra Packages for Enterprise Linux 6 - $basearch - Debug
        -baseurl=http://mirror.rackspace.com/epel/6/x86_64/
        -#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-6&arch=$basearch
         failovermethod=priority
        -enabled=0
        -gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
         gpgcheck=1
        -
        -[epel-source]
        -name=Extra Packages for Enterprise Linux 6 - $basearch - Source
        -baseurl=http://mirror.rackspace.com/epel/6/x86_64/
        -#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-source-6&arch=$basearch
        -failovermethod=priority
        -enabled=0
        -gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
        -gpgcheck=1
        +gpgkey=http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
        +mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch
        +sslverify=1

[2014-03-17T16:26:54+00:00] INFO: template[/etc/yum.repos.d/epel.repo] sending run action to execute[yum-makecache-epel] (immediate)
  * execute[yum-makecache-epel] action run[2014-03-17T16:27:02+00:00] INFO: execute[yum-makecache-epel] ran successfully

    - execute yum -q makecache --disablerepo=* --enablerepo=epel

[2014-03-17T16:27:02+00:00] INFO: template[/etc/yum.repos.d/epel.repo] sending create action to ruby_block[yum-cache-reload-epel] (immediate)
  * ruby_block[yum-cache-reload-epel] action create[2014-03-17T16:27:02+00:00] INFO: ruby_block[yum-cache-reload-epel] called

    - execute the ruby block yum-cache-reload-epel

  * execute[yum-makecache-epel] action nothing (skipped due to action :nothing)
  * ruby_block[yum-cache-reload-epel] action nothing (skipped due to action :nothing)


Recipe: utils::default
  * package[dstat] action install[2014-03-17T16:27:06+00:00] INFO: package[dstat] installing dstat-0.7.0-1.el6 from base repository

    - install version 0.7.0-1.el6 of package dstat

  * package[htop] action install[2014-03-17T16:27:08+00:00] INFO: package[htop] installing htop-1.0.1-2.el6 from epel repository

    - install version 1.0.1-2.el6 of package htop

  * package[sysstat] action install[2014-03-17T16:27:10+00:00] INFO: package[sysstat] installing sysstat-9.0.4-22.el6 from base repository

    - install version 9.0.4-22.el6 of package sysstat

  * package[tmux] action install[2014-03-17T16:27:11+00:00] INFO: package[tmux] installing tmux-1.6-3.el6 from epel repository

    - install version 1.6-3.el6 of package tmux

  * package[tree] action install[2014-03-17T16:27:13+00:00] INFO: package[tree] installing tree-1.5.3-2.el6 from base repository

    - install version 1.5.3-2.el6 of package tree

  * package[unzip] action install[2014-03-17T16:27:14+00:00] INFO: package[unzip] installing unzip-6.0-1.el6 from base repository

    - install version 6.0-1.el6 of package unzip

  * execute[install_dstat_with_mongodb_plugin] action run (skipped due to not_if)
  * execute[install_mongo_hacker] action runArchive:  /tmp/master.zip
ed72587066183c309e298f30d3702032124cce37
   creating: /tmp/mongo-hacker-master/
 extracting: /tmp/mongo-hacker-master/.gitignore
  inflating: /tmp/mongo-hacker-master/Makefile
  inflating: /tmp/mongo-hacker-master/README.md
  inflating: /tmp/mongo-hacker-master/base.js
  inflating: /tmp/mongo-hacker-master/config.js
   creating: /tmp/mongo-hacker-master/hacks/
  inflating: /tmp/mongo-hacker-master/hacks/aggregation.js
  inflating: /tmp/mongo-hacker-master/hacks/api.js
  inflating: /tmp/mongo-hacker-master/hacks/auto_complete.js
  inflating: /tmp/mongo-hacker-master/hacks/cmd_search.js
  inflating: /tmp/mongo-hacker-master/hacks/color.js
  inflating: /tmp/mongo-hacker-master/hacks/common.js
  inflating: /tmp/mongo-hacker-master/hacks/find_and_modify.js
  inflating: /tmp/mongo-hacker-master/hacks/helpers.js
 extracting: /tmp/mongo-hacker-master/hacks/index_paranoia.js
  inflating: /tmp/mongo-hacker-master/hacks/old_aggregation.js
  inflating: /tmp/mongo-hacker-master/hacks/prompt.js
  inflating: /tmp/mongo-hacker-master/hacks/sh_status.js
  inflating: /tmp/mongo-hacker-master/hacks/show.js
  inflating: /tmp/mongo-hacker-master/hacks/uuid.js
  inflating: /tmp/mongo-hacker-master/hacks/verbose.js
  inflating: /tmp/mongo-hacker-master/package.json
cat base.js config.js hacks/aggregation.js hacks/api.js hacks/auto_complete.js hacks/cmd_search.js hacks/color.js hacks/common.js hacks/find_and_modify.js hacks/helpers.js hacks/index_paranoia.js hacks/old_aggregation.js hacks/prompt.js hacks/sh_status.js hacks/show.js hacks/uuid.js hacks/verbose.js > mongo_hacker.js
INSTALLATION
Linking MongoHacker to .mongorc.js in your home directory:
ln -s "/tmp/mongo-hacker-master/mongo_hacker.js" ~/.mongorc.js
[2014-03-17T16:27:16+00:00] INFO: execute[install_mongo_hacker] ran successfully

    - execute curl -o /tmp/master.zip -L https://github.com/TylerBrock/mongo-hacker/archive/master.zip && unzip /tmp/master.zip -d /tmp/ && cd /tmp/mongo-hacker-master && make && ln -f mongo_hacker.js /root/.mongorc.js && chown root:    /root/.mongorc.js && rm -rf /tmp/{mongo-hacker-master,master.zip}

  * execute[clean_up_vagrant_omnibus] action run[2014-03-17T16:27:16+00:00] INFO: execute[clean_up_vagrant_omnibus] ran successfully

    - execute rm -f /root/install.sh

  * cookbook_file[public_ip] action create[2014-03-17T16:27:16+00:00] INFO: cookbook_file[public_ip] created file /root/public_ip

    - create new file /root/public_ip[2014-03-17T16:27:16+00:00] INFO: cookbook_file[public_ip] updated file contents /root/public_ip

    - update content in file /root/public_ip from none to f833d2
        --- /root/public_ip 2014-03-17 16:27:16.000000000 +0000
        +++ /tmp/.public_ip20140317-2081-6sejkw 2014-03-17 16:27:16.000000000 +0000
        @@ -1 +1,3 @@
        +#!/bin/sh
        +curl http://ipecho.net/plain ; echo[2014-03-17T16:27:16+00:00] INFO: cookbook_file[public_ip] owner changed to 0
[2014-03-17T16:27:16+00:00] INFO: cookbook_file[public_ip] group changed to 0
[2014-03-17T16:27:16+00:00] INFO: cookbook_file[public_ip] mode changed to 755

    - change mode from '' to '0755'
    - change owner from '' to 'root'
    - change group from '' to 'root'

Recipe: mongodb::10gen_repo
  * yum_repository[10gen] action addRecipe: <Dynamically Defined Resource>
  * template[/etc/yum.repos.d/10gen.repo] action create[2014-03-17T16:27:16+00:00] INFO: template[/etc/yum.repos.d/10gen.repo] created file /etc/yum.repos.d/10gen.repo

    - create new file /etc/yum.repos.d/10gen.repo[2014-03-17T16:27:16+00:00] INFO: template[/etc/yum.repos.d/10gen.repo] updated file contents /etc/yum.repos.d/10gen.repo

    - update content in file /etc/yum.repos.d/10gen.repo from none to cfcfb6
        --- /etc/yum.repos.d/10gen.repo 2014-03-17 16:27:16.000000000 +0000
        +++ /tmp/chef-rendered-template20140317-2081-olo24i 2014-03-17 16:27:16.000000000 +0000
        @@ -1 +1,10 @@
        +# This file was generated by Chef
        +# Do NOT modify this file by hand.
        +
        +[10gen]
        +name=10gen RPM Repository
        +baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
        +enabled=1
        +gpgcheck=1
        +sslverify=1[2014-03-17T16:27:16+00:00] INFO: template[/etc/yum.repos.d/10gen.repo] mode changed to 644

    - change mode from '' to '0644'

[2014-03-17T16:27:16+00:00] INFO: template[/etc/yum.repos.d/10gen.repo] sending run action to execute[yum-makecache-10gen] (immediate)
  * execute[yum-makecache-10gen] action run[2014-03-17T16:27:17+00:00] INFO: execute[yum-makecache-10gen] ran successfully

    - execute yum -q makecache --disablerepo=* --enablerepo=10gen

[2014-03-17T16:27:17+00:00] INFO: template[/etc/yum.repos.d/10gen.repo] sending create action to ruby_block[yum-cache-reload-10gen] (immediate)
  * ruby_block[yum-cache-reload-10gen] action create[2014-03-17T16:27:17+00:00] INFO: ruby_block[yum-cache-reload-10gen] called

    - execute the ruby block yum-cache-reload-10gen

  * execute[yum-makecache-10gen] action nothing (skipped due to action :nothing)
  * ruby_block[yum-cache-reload-10gen] action nothing (skipped due to action :nothing)


Recipe: mongodb::install
  * file[/etc/sysconfig/mongodb] action create_if_missing[2014-03-17T16:27:17+00:00] INFO: file[/etc/sysconfig/mongodb] created file /etc/sysconfig/mongodb

    - create new file /etc/sysconfig/mongodb[2014-03-17T16:27:17+00:00] INFO: file[/etc/sysconfig/mongodb] updated file contents /etc/sysconfig/mongodb

    - update content in file /etc/sysconfig/mongodb from none to a35762
        --- /etc/sysconfig/mongodb  2014-03-17 16:27:17.000000000 +0000
        +++ /tmp/.mongodb20140317-2081-kex398   2014-03-17 16:27:17.000000000 +0000
        @@ -1 +1,2 @@
        +ENABLE_MONGODB=no[2014-03-17T16:27:17+00:00] INFO: file[/etc/sysconfig/mongodb] owner changed to 0
[2014-03-17T16:27:17+00:00] INFO: file[/etc/sysconfig/mongodb] group changed to 0
[2014-03-17T16:27:17+00:00] INFO: file[/etc/sysconfig/mongodb] mode changed to 644

    - change mode from '' to '0644'
    - change owner from '' to 'root'
    - change group from '' to 'root'

  * template[/etc/mongodb.conf] action create_if_missing[2014-03-17T16:27:17+00:00] INFO: template[/etc/mongodb.conf] created file /etc/mongodb.conf

    - create new file /etc/mongodb.conf[2014-03-17T16:27:17+00:00] INFO: template[/etc/mongodb.conf] updated file contents /etc/mongodb.conf

    - update content in file /etc/mongodb.conf from none to bc6917
        --- /etc/mongodb.conf   2014-03-17 16:27:17.000000000 +0000
        +++ /tmp/chef-rendered-template20140317-2081-1fpyete    2014-03-17 16:27:17.000000000 +0000
        @@ -1 +1,14 @@
        +#
        +# Automatically Generated by Chef, do not edit directly!
        +#
        +
        +bind_ip = 0.0.0.0
        +dbpath = /data
        +fork = true
        +logappend = true
        +logpath = /var/log/mongodb/mongodb.log
        +nojournal = false
        +port = 27017
        +rest = false
        +smallfiles = true[2014-03-17T16:27:17+00:00] INFO: template[/etc/mongodb.conf] owner changed to 0
[2014-03-17T16:27:17+00:00] INFO: template[/etc/mongodb.conf] group changed to 0
[2014-03-17T16:27:17+00:00] INFO: template[/etc/mongodb.conf] mode changed to 644

    - change mode from '' to '0644'
    - change owner from '' to 'root'
    - change group from '' to 'root'

  * template[/etc/init.d/mongod] action create_if_missing[2014-03-17T16:27:17+00:00] INFO: template[/etc/init.d/mongod] created file /etc/init.d/mongod

    - create new file /etc/init.d/mongod[2014-03-17T16:27:17+00:00] INFO: template[/etc/init.d/mongod] updated file contents /etc/init.d/mongod

    - update content in file /etc/init.d/mongod from none to 7b414a
        --- /etc/init.d/mongod  2014-03-17 16:27:17.000000000 +0000
        +++ /tmp/chef-rendered-template20140317-2081-5y937a 2014-03-17 16:27:17.000000000 +0000
        @@ -1 +1,108 @@
        +#!/bin/bash
        +
        +# mongod - Startup script for mongod
        +
        +# chkconfig: 35 85 15
        +# description: Mongo is a scalable, document-oriented database.
        +# processname: mongod
        +# config: /etc/mongod.conf
        +# pidfile: /var/run/mongo/mongo.pid
        +
        +. /etc/rc.d/init.d/functions
        +
        +NAME=mongod
        +SYSCONFIG=/etc/sysconfig/mongodb
        +DAEMON_USER=mongod
        +ENABLE_MONGODB=yes
        +
        +SUBSYS_LOCK_FILE=/var/lock/subsys/mongod
        +
        +if [ -f "$SYSCONFIG" ]; then
        +    . "$SYSCONFIG"
        +fi
        +
        +# FIXME: 1.9.x has a --shutdown flag that parses the config file and
        +# shuts down the correct running pid, but that's unavailable in 1.8
        +# for now.  This can go away when this script stops supporting 1.8.
        +DBPATH=`awk -F= '/^dbpath[[:blank:]]*=[[:blank:]]*/{print $2}' "$CONFIGFILE"`
        +PIDFILE=`awk -F= '/^pidfilepath[[:blank:]]*=[[:blank:]]*/{print $2}' "$CONFIGFILE"`
        +
        +# Handle NUMA access to CPUs (SERVER-3574)
        +# This verifies the existence of numactl as well as testing that the command works
        +NUMACTL_ARGS="--interleave=all"
        +if which numactl >/dev/null 2>/dev/null && numactl $NUMACTL_ARGS ls / >/dev/null 2>/dev/null
        +then
        +    NUMACTL="numactl $NUMACTL_ARGS"
        +else
        +    NUMACTL=""
        +fi
        +
        +start()
        +{
        +  echo -n $"Starting mongod: "
        +  daemon --user "$DAEMON_USER" $NUMACTL $DAEMON $DAEMON_OPTS
        +  RETVAL=$?
        +  echo
        +  [ $RETVAL -eq 0 ] && touch $SUBSYS_LOCK_FILE
        +}
        +
        +stop()
        +{
        +  echo -n $"Stopping mongod: "
        +  if test "x$PIDFILE" != "x"; then
        +    killproc -p $PIDFILE -d 300 $DAEMON
        +  else
        +    killproc -d 300 $DAEMON
        +  fi
        +  RETVAL=$?
        +  echo
        +  [ $RETVAL -eq 0 ] && rm -f $SUBSYS_LOCK_FILE
        +}
        +
        +restart () {
        +  stop
        +  start
        +}
        +
        +ulimit -f unlimited
        +ulimit -t unlimited
        +ulimit -v unlimited
        +ulimit -n 64000
        +ulimit -m unlimited
        +ulimit -u 32000
        +
        +RETVAL=0
        +
        +if test "x$ENABLE_MONGODB" != "xyes"; then
        +    exit $RETVAL
        +fi
        +
        +case "$1" in
        +  start)
        +    start
        +    ;;
        +  stop)
        +    stop
        +    ;;
        +  restart|reload|force-reload)
        +    restart
        +    ;;
        +  condrestart)
        +    [ -f $SUBSYS_LOCK_FILE ] && restart || :
        +    ;;
        +  status)
        +    if test "x$PIDFILE" != "x"; then
        +      status -p $PIDFILE $DAEMON
        +    else
        +      status $DAEMON
        +    fi
        +    RETVAL=$?
        +    ;;
        +  *)
        +    echo "Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart}"
        +    RETVAL=1
        +esac
        +
        +exit $RETVAL
        +[2014-03-17T16:27:17+00:00] INFO: template[/etc/init.d/mongod] owner changed to 0
[2014-03-17T16:27:17+00:00] INFO: template[/etc/init.d/mongod] group changed to 0
[2014-03-17T16:27:17+00:00] INFO: template[/etc/init.d/mongod] mode changed to 755

    - change mode from '' to '0755'
    - change owner from '' to 'root'
    - change group from '' to 'root'

[2014-03-17T16:27:17+00:00] INFO: template[/etc/init.d/mongod] not queuing delayed action restart on service[mongod] (delayed), as it's already been queued
  * package[mongo-10gen-server] action install[2014-03-17T16:27:20+00:00] INFO: package[mongo-10gen-server] installing mongo-10gen-server-2.4.9-mongodb_1 from 10gen repository

    - install version 2.4.9-mongodb_1 of package mongo-10gen-server

Recipe: mongodb::default
  * template[/etc/sysconfig/mongodb] action create[2014-03-17T16:27:34+00:00] INFO: template[/etc/sysconfig/mongodb] backed up to /var/chef/backup/etc/sysconfig/mongodb.chef-20140317162734.171517
[2014-03-17T16:27:34+00:00] INFO: template[/etc/sysconfig/mongodb] updated file contents /etc/sysconfig/mongodb

    - update content in file /etc/sysconfig/mongodb from a35762 to 75458b
        --- /etc/sysconfig/mongodb  2014-03-17 16:27:17.000000000 +0000
        +++ /tmp/chef-rendered-template20140317-2081-19k0jqq    2014-03-17 16:27:34.000000000 +0000
        @@ -1,2 +1,13 @@
        -ENABLE_MONGODB=no
        +#
        +# Automatically Generated by Chef, do not edit directly!
        +#
        +
        +CONFIGFILE="/etc/mongodb.conf"
        +DAEMON="/usr/bin/$NAME"
        +DAEMONUSER="mongod"
        +DAEMON_OPTS="--config /etc/mongodb.conf"
        +DAEMON_USER="mongod"
        +ENABLE_MONGO="yes"
        +ENABLE_MONGOD="yes"
        +ENABLE_MONGODB="yes"

[2014-03-17T16:27:34+00:00] INFO: template[/etc/sysconfig/mongodb] not queuing delayed action restart on service[mongod] (delayed), as it's already been queued
  * template[/etc/mongodb.conf] action create (up to date)
  * directory[/var/log/mongodb] action create[2014-03-17T16:27:34+00:00] INFO: directory[/var/log/mongodb] created directory /var/log/mongodb

    - create new directory /var/log/mongodb[2014-03-17T16:27:34+00:00] INFO: directory[/var/log/mongodb] owner changed to 498
[2014-03-17T16:27:34+00:00] INFO: directory[/var/log/mongodb] group changed to 499
[2014-03-17T16:27:34+00:00] INFO: directory[/var/log/mongodb] mode changed to 755

    - change mode from '' to '0755'
    - change owner from '' to 'mongod'
    - change group from '' to 'mongod'

  * directory[/data] action create[2014-03-17T16:27:34+00:00] INFO: directory[/data] owner changed to 498
[2014-03-17T16:27:34+00:00] INFO: directory[/data] group changed to 499

    - change owner from 'root' to 'mongod'
    - change group from 'root' to 'mongod'

  * template[/etc/init.d/mongod] action create[2014-03-17T16:27:34+00:00] INFO: template[/etc/init.d/mongod] backed up to /var/chef/backup/etc/init.d/mongod.chef-20140317162734.184807
[2014-03-17T16:27:34+00:00] INFO: template[/etc/init.d/mongod] updated file contents /etc/init.d/mongod

    - update content in file /etc/init.d/mongod from 59d2df to 7b414a
        --- /etc/init.d/mongod  2014-01-10 20:43:45.000000000 +0000
        +++ /tmp/chef-rendered-template20140317-2081-199a93f    2014-03-17 16:27:34.000000000 +0000
        @@ -6,33 +6,27 @@
         # description: Mongo is a scalable, document-oriented database.
         # processname: mongod
         # config: /etc/mongod.conf
        -# pidfile: /var/run/mongo/mongod.pid
        +# pidfile: /var/run/mongo/mongo.pid

         . /etc/rc.d/init.d/functions

        -# things from mongod.conf get there by mongod reading it
        +NAME=mongod
        +SYSCONFIG=/etc/sysconfig/mongodb
        +DAEMON_USER=mongod
        +ENABLE_MONGODB=yes

        +SUBSYS_LOCK_FILE=/var/lock/subsys/mongod

        -# NOTE: if you change any OPTIONS here, you get what you pay for:
        -# this script assumes all options are in the config file.
        -CONFIGFILE="/etc/mongod.conf"
        -OPTIONS=" -f $CONFIGFILE"
        -SYSCONFIG="/etc/sysconfig/mongod"
        +if [ -f "$SYSCONFIG" ]; then
        +    . "$SYSCONFIG"
        +fi

         # FIXME: 1.9.x has a --shutdown flag that parses the config file and
         # shuts down the correct running pid, but that's unavailable in 1.8
         # for now.  This can go away when this script stops supporting 1.8.
        -DBPATH=`awk -F= '/^dbpath=/{print $2}' "$CONFIGFILE"`
        -PIDFILE=`awk -F= '/^dbpath\s=\s/{print $2}' "$CONFIGFILE"`
        -mongod=${MONGOD-/usr/bin/mongod}
        +DBPATH=`awk -F= '/^dbpath[[:blank:]]*=[[:blank:]]*/{print $2}' "$CONFIGFILE"`
        +PIDFILE=`awk -F= '/^pidfilepath[[:blank:]]*=[[:blank:]]*/{print $2}' "$CONFIGFILE"`

        -MONGO_USER=mongod
        -MONGO_GROUP=mongod
        -
        -if [ -f "$SYSCONFIG" ]; then
        -    . "$SYSCONFIG"
        -fi
        -
         # Handle NUMA access to CPUs (SERVER-3574)
         # This verifies the existence of numactl as well as testing that the command works
         NUMACTL_ARGS="--interleave=all"
        @@ -46,29 +40,43 @@
         start()
         {
           echo -n $"Starting mongod: "
        -  daemon --user "$MONGO_USER" $NUMACTL $mongod $OPTIONS
        +  daemon --user "$DAEMON_USER" $NUMACTL $DAEMON $DAEMON_OPTS
           RETVAL=$?
           echo
        -  [ $RETVAL -eq 0 ] && touch /var/lock/subsys/mongod
        +  [ $RETVAL -eq 0 ] && touch $SUBSYS_LOCK_FILE
         }

         stop()
         {
           echo -n $"Stopping mongod: "
        -  killproc -p "$PIDFILE" -d 300 /usr/bin/mongod
        +  if test "x$PIDFILE" != "x"; then
        +    killproc -p $PIDFILE -d 300 $DAEMON
        +  else
        +    killproc -d 300 $DAEMON
        +  fi
           RETVAL=$?
           echo
        -  [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/mongod
        +  [ $RETVAL -eq 0 ] && rm -f $SUBSYS_LOCK_FILE
         }

         restart () {
        -   stop
        -   start
        +  stop
        +  start
         }

        -ulimit -n 12000
        +ulimit -f unlimited
        +ulimit -t unlimited
        +ulimit -v unlimited
        +ulimit -n 64000
        +ulimit -m unlimited
        +ulimit -u 32000
        +
         RETVAL=0

        +if test "x$ENABLE_MONGODB" != "xyes"; then
        +    exit $RETVAL
        +fi
        +
         case "$1" in
           start)
             start
        @@ -80,10 +88,14 @@
             restart
             ;;
           condrestart)
        -    [ -f /var/lock/subsys/mongod ] && restart || :
        +    [ -f $SUBSYS_LOCK_FILE ] && restart || :
             ;;
           status)
        -    status $mongod
        +    if test "x$PIDFILE" != "x"; then
        +      status -p $PIDFILE $DAEMON
        +    else
        +      status $DAEMON
        +    fi
             RETVAL=$?
             ;;
           *)
        @@ -92,4 +104,5 @@
         esac

         exit $RETVAL
        +

[2014-03-17T16:27:34+00:00] INFO: template[/etc/init.d/mongod] not queuing delayed action restart on service[mongod] (delayed), as it's already been queued
  * service[mongod] action enable (up to date)
  * service[mongod] action start[2014-03-17T16:27:34+00:00] INFO: service[mongod] started

    - start service service[mongod]

[2014-03-17T16:27:34+00:00] INFO: template[/etc/mongodb.conf] sending restart action to service[mongod] (delayed)
  * service[mongod] action restart[2014-03-17T16:27:35+00:00] INFO: service[mongod] restarted

    - restart service service[mongod]

[2014-03-17T16:27:35+00:00] INFO: Chef Run complete in 47.499079195 seconds

Running handlers:
[2014-03-17T16:27:35+00:00] INFO: Running report handlers
Running handlers complete

[2014-03-17T16:27:35+00:00] INFO: Report handlers complete
Chef Client finished, 32/34 resources updated in 47.887154265 seconds
[root@mongodb-vuafzbpl ~]# exit
logout
```
