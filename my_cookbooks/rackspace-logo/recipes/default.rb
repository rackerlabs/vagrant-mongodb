cookbook_file 'motd.tail' do
  path  '/etc/motd.tail'
  owner 'root'
  group 'root'
  mode  '0444'
  source 'rackspace-motd'
end
