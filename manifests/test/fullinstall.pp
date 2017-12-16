# Auth in MongoDB module with new versions of puppet causes an error
if versioncmp($::puppetversion, '4.0.0') >= 0 {
  $_mongodb_auth = false
}
else {
  $_mongodb_auth = true
}

class { '::st2':
  mongodb_auth         => $_mongodb_auth,
  chatops_adapter_conf => {
    'HUBOT_ADAPTER' => 'slack',
  },
}

include ::st2::profile::fullinstall
