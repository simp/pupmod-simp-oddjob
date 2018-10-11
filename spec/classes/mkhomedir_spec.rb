require 'spec_helper'

describe 'oddjob::mkhomedir' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts
    end

    context "on #{os}" do
      it { is_expected.to create_class('oddjob::mkhomedir') }
      it { is_expected.to compile.with_all_deps }

      context 'with umask 0117' do
        let(:params) {{ :umask => '0117' }}
        it { is_expected.to create_package('oddjob-mkhomedir') }
        it { is_expected.to create_file('/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf').that_notifies('Service[oddjobd]') }
        it { is_expected.to create_file('/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf').with_content(/-u #{params[:umask]}/) }
      end
    end
  end
end
