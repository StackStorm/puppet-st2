require 'spec_helper'

describe 'st2::profile::nginx' do
  on_supported_os.each do |os, os_facts|
    let(:facts) do
      os_facts.merge(
        sudoversion: '1.8.23',
      )
    end

    context "on #{os}" do
      context 'with default options' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_class('nginx').with(
            manage_repo: true,
            confd_purge: true)
        end
      end # context 'with default options'

      context 'with manage_repo=false' do
        let(:params) { { manage_repo: false } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_class('nginx').with(
            manage_repo: false,
            confd_purge: true)
        end
      end # context 'with manage_repo=false'
    end # context 'on #{os}'
  end # on_supported_os
end # describe 'st2::profile::nginx'
