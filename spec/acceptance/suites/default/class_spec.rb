require 'spec_helper_acceptance'

test_name 'oddjob class'

describe 'oddjob class' do
  let(:manifest) {
    <<-EOS
      include '::oddjob'
    EOS
  }

  context 'with defaults' do
    it 'should work with no errors' do
       apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
       apply_manifest(manifest, :catch_changes => true)
    end

    describe package('oddjob') do
      it { is_expected.to be_installed }
    end

    describe service('oddjobd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
