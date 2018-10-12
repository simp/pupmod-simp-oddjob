require 'spec_helper'

describe 'oddjob' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts
    end

    context "on #{os}" do
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('oddjob') }

      it { is_expected.to create_package('oddjob').with( :ensure => 'installed')}
      it { is_expected.to contain_service('oddjobd').with({
          :ensure  => 'running',
          :enable  => true,
          :require => 'Package[oddjob]'
        })
      }
    end
  end
end
