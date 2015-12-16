require 'spec_helper'

describe 'st2::package::debian' do
  context 'default parameters' do
    let (:facts) { FactHelper.ubuntu_trusty_x64 }

    it 'should download from download.stackstorm.com stable repo' do
      expect {
        should contain_apt__source('stackstorm').with(
                 'location'    => 'https://download.stackstorm.com/deb/',
                 'release'     => 'trusty_stable',
                 'repos'       => 'main',
                 'include_src' => false,
                 'key'         => '1E26DCC8B9D4E6FCB65CC22E40A96AE06B8C7982',
                 'key_source'  => 'https://download.stackstorm.com/deb/pubkey.gpg',
               )
      }
    end
  end

  context 'dl.bintray.com staging' do
    let (:facts) { FactHelper.ubuntu_trusty_x64 }
    let (:params) {
      {
        :repo_base => 'https://dl.bintray.com',
        :repo_env  => 'staging',
      }
    }

    it 'should download from dl.bintray.com staging repo' do
      expect {
        should contain_apt__source('stackstorm').with(
                 'location'    => 'https://dl.bintray.com/stackstorm/trusty_staging',
                 'release'     => 'unstable',
                 'repos'       => 'main',
                 'include_src' => false,
                 'key'         => 'A850304EED82AE89A136271F1AB74003483DED8B',
                 'key_source'  => 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray',
               )
      }
    end
  end

  context 'dl.bintray.com stable' do
    let (:facts) { FactHelper.ubuntu_trusty_x64 }
    let (:params) {
      {
        :repo_base => 'https://dl.bintray.com',
        :repo_env  => 'stable',
      }
    }
    it 'should download from dl.bintray.com stable repo' do
      expect {
        should contain_apt__source('stackstorm').with(
                 'location'    => '',
                 'release'     => '',
                 'repos'       => '',
                 'include_src' => '',
                 'key'         => '',
                 'key_source'  => '',
               )
      }
    end
  end

  context 'garbage input from the user' do
    let (:facts) { FactHelper.ubuntu_trusty_x64 }
    let (:params) {
      {
        :repo_base => 'snthaoeusnthaoelr[0g9\135c0rg]',
        :repo_env  => 'snthao,..[4098123[0gaoeuksnth]]',
      }
    }

    it 'should download from download.stackstorm.com 'do
      expect {
        should contain_apt__source('stackstorm').with(
                 'location'    => 'https://download.stackstorm.com/deb/',
                 'release'     => 'trusty_stable',
                 'repos'       => 'main',
                 'include_src' => false,
                 'key'         => '1E26DCC8B9D4E6FCB65CC22E40A96AE06B8C7982',
                 'key_source'  => 'https://download.stackstorm.com/deb/pubkey.gpg',
               )
      }
    end
  end
end
