#### Rackspace Cloud Servers

directory "/data" do
    owner "root"
    group "root"
    mode 0755
    action :create
end

# case provider
# when "rackspace"
#   if exists /dev/xvde1 and not mounted and no filesystem
#       format /dev/xvde1
#       mount data
# end

execute "format_data_disk" do
#    case filesystem
#    when "ext4"
    command 'mkfs.ext4 /dev/xvde1'
#    else
#        Chef::Log.info("Can't format filesystem #{filesystem}")
#    end
end

mount 'data' do
    device "/dev/xvde1"
    fstype "ext4"
    options "noatime,noexec"
    action [:mount, :enable]
end
