class st2::profile::python {
  if !defined(Class['::python']) {
    class { '::python':
      version    => 'system',
      pip        => true,
      dev        => true,
      virtualenv => true,
    }
  }

}
