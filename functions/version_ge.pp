# @summary Determines if the StackStorm version installed or the version requested
#          by the user is greater than or equal to <code>$version</code>.
#
# Determines if the StackStorm version installed on the system <code>$facts['st2_version']</code>
# or the version requested by the user <code>$::st2::version</code> is greater than or equal
# to <code>$version</code>.
#
# This is used to determine if this Puppet module should enable features for managing
# specific versions of StackStorm. Older versions of StackStorm will not have new features
# and we don't want this module to try and manage them if they're not present on the system.
#
# Users who have old version of StackStorm installed may have <code>$::st2::version = 'present'</code>
# or <code>$::st2::version = 'installed'</code>. In this case, we don't want to assume the user
# has a new version of StackStorm or wants to upgrade. Instead, we should assume that
# this the installed version of StackStorm is the version we should be using to compare.
#
# @param version
#   Version string to compare against. This should be in SemVer format
#
# @return [Boolean] True if the StackStorm version on the system or $::st2::version is
#                   >= to the +version+ parameter.
#
# @example Basic Usage
#   if st2::version_ge('2.4.0') {
#     # ... do something only for StackStorm version >= 2.4.0
#   }
#
function st2::version_ge(String $version) >> Boolean {
  # if StackStorm is not installed
  # if the current StackStorm version is >= compared version
  if ($facts['st2_version'] == undef or
      versioncmp($facts['st2_version'], $version) >= 0) {
    $ge = true
  }
  # if StackStorm is installed and its version ils < compared version and
  #    the user-requested StackStorm version is 'present' or
  #    the user-requested StackStorm version is 'installed'
  #  then the version is less (ie the user has installed an old version and we
  #  don't want to turn on features that may break their existing installation)
  elsif (versioncmp($facts['st2_version'], $version) < 0 and
          ($::st2::version == 'present' or
            $::st2::version == 'installed')) {
    $ge = false
  }
  # if the user-requested StackStorm version is 'latest' or
  #    the user-requested StackStorm version is >= compared version
  #  then the version is greater than, return true (user wants to use new stuff and upgrade)
  #
  # FYI, do this comparison LAST because versioncmp('preset', '2.1.0') returns 1 (true)
  #  ie. we need to compare against the known $::st2::versions before using versioncmp()
  #      with that variable.
  elsif ($::st2::version == 'latest' or
          versioncmp($::st2::version, $version) >= 0) {
    $ge = true
  }
  # otherwise version is less
  else {
    $ge = false
  }
  $ge
}
