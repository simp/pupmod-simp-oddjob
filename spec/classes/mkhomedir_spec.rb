require 'spec_helper'

describe 'oddjob::mkhomedir' do
  let(:facts) {{
    :fqdn => 'test.host.net',
    :hardwaremodel => 'x86_64',
    :processorcount => 4,
    :interfaces => 'lo',
    :ipaddress_lo => '127.0.0.1',
    :operatingsystem => 'RedHat'
  }}

  let(:params) {{ :umask => '0027' }}

  it { should create_class('oddjob') }
  it { should compile.with_all_deps }

  it { should create_package('oddjob-mkhomedir') }
  it { should create_file('/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf').that_notifies('Service[oddjobd]') }
  it { should create_file('/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf').with_content(/-u #{params[:umask]}/) }
end
