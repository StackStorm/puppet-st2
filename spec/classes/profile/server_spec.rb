require 'spec_helper'

describe 'st2::profile::server' do
  on_supported_os.each do |os, os_facts|
    let(:facts) do
      os_facts.merge(
        sudoversion: '1.8.23',
      )
    end

    context "on #{os} with default options" do
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('st2::profile::server') }

      it do
        is_expected.to contain_file('/opt/stackstorm').with(
          ensure: 'directory',
          owner: 'root',
          group: 'root',
          mode: '0755',
          tag: 'st2::server',
        )
      end

      it { is_expected.to contain_group('st2packs') }

      it do
        is_expected.to contain_file('/opt/stackstorm/configs').with(
          ensure: 'directory',
          owner: 'st2',
          group: 'root',
          mode: '0755',
          tag: 'st2::server',
        )
      end

      it do
        is_expected.to contain_file('/opt/stackstorm/packs').with(
          ensure: 'directory',
          owner: 'root',
          group: 'st2packs',
          tag: 'st2::server',
        )
      end

      it do
        is_expected.to contain_file('/opt/stackstorm/virtualenvs').with(
          ensure: 'directory',
          owner: 'root',
          group: 'st2packs',
          tag: 'st2::server',
        )
      end

      it do
        is_expected.to contain_recursive_file_permissions('/opt/stackstorm/packs').with(
          owner: 'root',
          group: 'st2packs',
          tag: 'st2::server',
        )
      end

      it do
        is_expected.to contain_recursive_file_permissions('/opt/stackstorm/virtualenvs').with(
          owner: 'root',
          group: 'st2packs',
          tag: 'st2::server',
        )
      end
    end # context 'on #{os} with default options'
  end # on_supported_os(all_os)
end # describe 'st2::profile::server'
