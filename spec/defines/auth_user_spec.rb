require 'spec_helper'
require 'helpers/fact_helper'

describe 'st2::auth_user' do
  let(:title) { 'stanley' }
  describe 'creates an htpasswd entry' do
    let (:facts) { FactHelper.ubuntu_trusty_x64 }
    let (:params) {
      {
        :ensure   => 'present',
        :password => 'sekritp3sswrd'
      }
    }

    it do
      should contain_httpauth('stanley').with(
        :ensure   => 'present',
        :password => 'sekritp3sswrd'
      )
    end
  end
end
