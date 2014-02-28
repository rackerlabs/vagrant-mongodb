cookbook_file 'motd' do
  path  '/etc/motd'
  owner 'root'
  group 'root'
  mode  '0444'
  source 'rackspace-motd'
end
