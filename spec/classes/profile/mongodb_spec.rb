require 'spec_helper'

describe 'st2::profile::mongodb' do
  # let(:latest_version) { '4.0' }

  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    if os == "ubuntu-20.04-x86_64"
      let(:latest_version) { '4.4' }

    else
      let(:latest_version) { '4.0' }

    end
    context "on #{os}" do
      context 'with default options' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_class('mongodb::globals')
            .with('manage_package' => true,
                  'manage_package_repo' => true,
                  'version' => latest_version,
                  'manage_pidfile' => false)
        end
        it { is_expected.to contain_class('mongodb::client') }
        it do
          is_expected.to contain_class('mongodb::server')
            .with('port' => 27_017,
                  'auth' => true,
                  'create_admin' => true,
                  'store_creds' => true,
                  'admin_username' => 'admin',
                  'admin_password' => 'Ch@ngeMe')
        end
        it do
          is_expected.to contain_mongodb__db('st2')
            .with('user' => 'stackstorm',
                  'password' => 'Ch@ngeMe',
                  'roles' => ['readWrite'])
            .that_requires('Class[mongodb::server]')
        end
      end

      context 'with st2_version == 3.3.0' do
        let(:facts) { os_facts.merge('st2_version' => '3.3.0') }
        
        it do
          if os == "ubuntu-20.04-x86_64"
            is_expected.to contain_class('mongodb::globals')
            .with('manage_package' => true,
                  'manage_package_repo' => true,
                  'version' => '4.4',
                  'manage_pidfile' => false)
      
          else
            is_expected.to contain_class('mongodb::globals')
            .with('manage_package' => true,
                  'manage_package_repo' => true,
                  'version' => '4.0',
                  'manage_pidfile' => false)
      
          end
        end
      end

      context 'with st2_version == 2.4.0' do
        let(:facts) { os_facts.merge('st2_version' => '2.4.0') }

        it do
          is_expected.to contain_class('mongodb::globals')
            .with('manage_package' => true,
                  'manage_package_repo' => true,
                  'version' => '3.4',
                  'manage_pidfile' => false)
        end
      end

      context 'with st2::version == 2.3.0' do
        let(:facts) { os_facts.merge('st2_version' => '2.3.0') }

        it do
          is_expected.to contain_class('mongodb::globals')
            .with('manage_package' => true,
                  'manage_package_repo' => true,
                  'version' => '3.2',
                  'manage_pidfile' => false)
        end
      end

      context 'with mongodb version explicitly specified' do
        let(:params) { { 'version' => '3.4' } }

        it do
          is_expected.to contain_class('mongodb::globals')
            .with('manage_package' => true,
                  'manage_package_repo' => true,
                  'version' => '3.4',
                  'manage_pidfile' => false)
        end
      end

      context 'when MongoDB is already declared' do
        let(:pre_condition) { 'include mongodb::server' }

        it { is_expected.to contain_class('mongodb::server').with }
      end

      context 'with auth disabled' do
        let(:params) { { 'auth' => false } }

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_class('mongodb::globals')
            .with('manage_package' => true,
                  'manage_package_repo' => true,
                  'version' => latest_version,
                  'manage_pidfile' => false)
        end
        it { is_expected.to contain_class('mongodb::client') }
        it { is_expected.to contain_class('mongodb::server').with('port' => 27_017) }
        it do
          is_expected.to contain_mongodb__db('st2')
            .with('user' => 'stackstorm',
                  'password' => 'Ch@ngeMe',
                  'roles' => ['readWrite'])
            .that_requires('Class[mongodb::server]')
        end
      end
    end
  end
end
