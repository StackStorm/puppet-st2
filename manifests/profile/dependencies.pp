# == Class: st2::profile::dependencies
#
#  Profile to install all requirements to run st2
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  include st2::profile::dependencies
#
class st2::profile::dependencies {
  include ::st2::profile::python

  ### This should be a versioned download too... currently on master
  wget::fetch { 'Download st2server requirements.txt':
    source      => 'https://raw.githubusercontent.com/StackStorm/st2/master/requirements.txt',
    cache_dir   => '/var/cache/wget',
    destination => '/tmp/st2server-requirements.txt',
  }

  python::requirements { '/tmp/st2server-requirements.txt':
    require => Wget::Fetch['Download st2server requirements.txt'],
    before  => Exec['register st2 content'],
  }

  ### This should be a versioned download too... currently on master
  wget::fetch { 'Download st2client requirements.txt':
    source      => 'https://raw.githubusercontent.com/StackStorm/st2/master/st2client/requirements.txt',
    cache_dir   => '/var/cache/wget',
    destination => '/tmp/st2client-requirements.txt',
  }

  python::requirements { '/tmp/st2client-requirements.txt':
    require => Wget::Fetch['Download st2client requirements.txt'],
  }
}
