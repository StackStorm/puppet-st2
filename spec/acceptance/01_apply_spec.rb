require 'spec_helper_acceptance'

describe 'apply' do
  context 'when full install' do
    let(:pp) do
      <<-MANIFEST
        class { 'sudo':
          purge => false,
        }
        contain st2::profile::fullinstall
      MANIFEST
    end

    it 'applies the manifest twice with no stderr' do
      idempotent_apply(pp)
    end
  end
end
