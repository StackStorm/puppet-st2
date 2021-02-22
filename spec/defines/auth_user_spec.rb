require 'spec_helper'

describe 'st2::auth_user' do
  let(:title) { 'stanley' }

  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    describe "on #{os} creates an htpasswd entry" do
      let(:params) do
        {
          ensure:    'present',
          password: 'sekritp3sswrd',
        }
      end

      it do
        is_expected.to contain_httpauth('stanley')
          .with(ensure:   'present',
                password: 'sekritp3sswrd')
      end
    end
  end
end
