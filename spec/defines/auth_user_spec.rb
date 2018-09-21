require 'spec_helper'
require 'helpers/fact_helper'

describe 'st2::auth_user' do
  let(:title) { 'stanley' }

  describe 'creates an htpasswd entry' do
    let(:facts) { FactHelper.ubuntu_trusty_x64 }
    let(:params) do
      {
        ensure:    'present',
        password: 'sekritp3sswrd',
      }
    end

    it do
      is_expected.to contain_httpauth('stanley').with(
        ensure:   'present',
        password: 'sekritp3sswrd',
      )
    end
  end
end
