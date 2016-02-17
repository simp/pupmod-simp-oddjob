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

  it { is_expected.to create_class('oddjob') }
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to create_package('oddjob-mkhomedir') }
  it { is_expected.to create_file('/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf').that_notifies('Service[oddjobd]') }
  it { is_expected.to create_file('/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf').with_content(/-u #{params[:umask]}/) }
end
