# @summary Creates additional service for components that can be scaled out
#
# @param service_name
#    The service name that we are attempting to scale
# @param service_num
#    The number of servicees that should be scaled out
# @param existing_services
#    The service to make sure are enabled and running. All new service
#    are automatically added to this.
#
# @example build st2workflowengine service
#  st2::service { 'st2workflowengine':
#    service_name => 'st2workflowengine-rsa',
#    service_num => '2',
#    existing_services => ['st2workflowengine'],
#  }
#
define st2::service(
  $service_name,
  $service_num,
  $existing_services,
) {
  if ($service_num > 1) {
    $additional_service = range('2', $service_num).reduce([]) |$memo, $number| {
      $new_service_name = "${service_name}${number}"
      case $facts['os']['family'] {
        'RedHat': {
          $file_path = '/usr/lib/systemd/system/'
        }
        'Debian': {
          $file_path = '/lib/systemd/system/'
        }
        default: {
          fail("Unsupported managed repository for osfamily: ${facts['os']['family']}, operatingsystem: ${facts['os']['name']}")
        }
      }

      systemd::unit_file { "${new_service_name}.service":
        path   => $file_path,
        source => "${file_path}${service_name}.service",
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      $memo + [$new_service_name]
    }

    $_existing_services = $existing_services + $additional_service

  } else {
    $_existing_services = $existing_services
  }

  ########################################
  ## Service
  service { $_existing_services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }
}
