# Install monitoring tools
package 'dstat'
package 'htop'
package 'sysstat'

# Install other useful utils
package 'tmux'
package 'tree'
package 'unzip'

execute 'install_dstat_with_mongodb_plugin' do
  command 'curl -o /usr/share/dstat/dstat_mongodb_cmds.py -L https://raw.github.com/gianpaj/dstat/master/plugins/dstat_mongodb_cmds.py'
  not_if { FileTest.directory?('/usr/share/dstat/') }
end

execute 'install_mongo_hacker' do
  command [
    'curl -o /tmp/master.zip -L https://github.com/TylerBrock/mongo-hacker/archive/master.zip',
    'unzip /tmp/master.zip -d /tmp/',
    'cd /tmp/mongo-hacker-master',
    'make',
    'ln -f mongo_hacker.js /root/.mongorc.js',
    'chown root:    /root/.mongorc.js',
    'rm -rf /tmp/{mongo-hacker-master,master.zip}'
  ].join(' && ')
  not_if { ::File.exists?('/root/.mongorc.js') }
end

execute 'clean_up_vagrant_omnibus' do
  command 'rm -f /root/install.sh'
end

cookbook_file 'public_ip' do
  path  '/root/public_ip'
  owner 'root'
  group 'root'
  mode  '0755'
end

directory "/data" do
    owner "root"
    group "root"
    mode 0755
    action :create
end

#### Rackspace Cloud Servers
#
# case provider
# when "rackspace"
#   if exists /dev/xvde1 and not mounted and no filesystem
#       format /dev/xvde1
#       mount data
# end

# add to rackspace section
execute "format_data_disk" do
#    case filesystem
#    when "ext4"
    command 'mkfs.ext4 /dev/xvde1'
#    else
#        Chef::Log.info("Can't format filesystem #{filesystem}")
#    end
end

# add to rackspace section
mount 'data' do
    device "/dev/xvde1"
    fstype "ext4"
    options "noatime,noexec"
    action [:mount, :enable]
end


