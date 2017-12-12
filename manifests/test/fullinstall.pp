class { '::st2':
  chatops_adapter_conf => {
    HUBOT_ADAPTER => 'slack',
  },
}

include ::st2::profile::fullinstall
