require 'spec_helper'

describe 'oddjob' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) {{
        :fqdn => 'test.host.net',
        :hardwaremodel => 'x86_64',
        :processorcount => 4,
        :interfaces => 'lo',
        :ipaddress_lo => '127.0.0.1',
        :operatingsystem => 'RedHat',  
        :operatingsystem => 'CentOS' 
      }}
      let(:facts) do
        facts
      end  

      context "on #{os}" do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('oddjob') }

      context 'base' do 
        it { is_expected.to create_package('oddjob').with( :ensure => 'latest')}
#        it { is_expected.to contain_service('oddjob') }
#        it { is_expected.to contain_service('oddjob').with({
#          :ensure     => 'running',
#          :enable     => 'true' } )
#        }   
      end
    end
  end
end
end

