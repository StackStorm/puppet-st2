require 'spec_helper'

describe 'st2::pack' do
  let(:title) { 'st2testpack' }

  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os}" do
      context 'when declared with config' do
        let(:params) do
          {
            repo_url: 'https://git.company.com/repos/packs/pack.git',
            config: {
              foo: 'bar',
            },
          }
        end

        it { is_expected.to contain_st2_pack('st2testpack') }
        it do
          is_expected.to contain_file('/opt/stackstorm/configs/st2testpack.yaml')
            .with(ensure: 'file',
                  owner: 'st2',
                  group: 'root',
                  mode: '0640')
        end
      end

      context 'when declared with default parameters' do
        it do
          is_expected.to contain_st2_pack('st2testpack')
            .with(ensure: 'present',
                  user: 'st2admin',
                  password: 'Ch@ngeMe')
        end
      end

      context 'when declared with explicit source' do
        let(:params) { { repo_url: 'https://git.company.com/repos/packs/pack.git' } }

        it do
          is_expected.to contain_st2_pack('st2testpack')
            .with(ensure: 'present',
                  user: 'st2admin',
                  password: 'Ch@ngeMe',
                  source: 'https://git.company.com/repos/packs/pack.git')
        end
      end

      context 'when declared with non-default user and password' do
        let(:pre_condition) { 'class {"st2": cli_password => "test_bar", cli_username => "test_foo"}' }

        it do
          is_expected.to contain_st2_pack('st2testpack')
            .with(ensure: 'present',
                  user: 'test_foo',
                  password: 'test_bar')
        end
      end

      context 'when defining a package absent' do
        let(:params) { { ensure: 'absent' } }

        it do
          is_expected.to contain_st2_pack('st2testpack')
            .with(ensure: 'absent',
                  user: 'st2admin',
                  password: 'Ch@ngeMe')
        end
      end
    end
  end
end
