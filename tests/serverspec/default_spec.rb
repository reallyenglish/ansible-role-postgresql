require "spec_helper"
require "serverspec"

package = "postgresql"
service = "postgresql"
config  = "/etc/postgresql/postgresql.conf"
user    = "postgresql"
group   = "postgresql"
ports   = [5432]
# log_dir = "/var/log/postgresql"
db_dir  = "/var/lib/postgresql"

case os[:family]
when "freebsd"
  user = "pgsql"
  group = "pgsql"
  package = "postgresql95-server"
  config = "/usr/local/pgsql/data/postgresql.conf"
  db_dir = "/usr/local/pgsql/data"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("log_destination = 'syslog'") }
  its(:content) { should match(/max_connections = 100/) }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 700 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

# case os[:family]
# when 'freebsd'
#   describe file('/etc/rc.conf.d/postgresql') do
#     it { should be_file }
#   end
# end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
