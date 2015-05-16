require 'spec_helper'

describe 'oddjob' do
  let(:facts) {{
    :fqdn => 'test.host.net',
    :hardwaremodel => 'x86_64',
    :processorcount => 4,
    :interfaces => 'lo',
    :ipaddress_lo => '127.0.0.1',
    :operatingsystem => 'RedHat'
  }}

  it { should create_class('oddjob') }
  it { should compile.with_all_deps }

  it { should create_package('oddjob') }
  it { should create_service('oddjobd').that_requires('Package[oddjob]') }
end
