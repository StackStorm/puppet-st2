# == Class: st2::stanley
#
#  Installs the default admin user for st2 (stanley). Will install
#  insecure keys by default to allow testing, but also allows override of
#  values.
#
# === Parameters
#  [*ssh_public_key*]  - SSH Public Key without leading key-type and end email
#  [*ssh_key_type*]    - Type of SSH Key (ssh-dsa/ssh-rsa)
#  [*ssh_private_key*] - Private key
#  [*client*]          - Allow incoming connections from the defined user (default: true)
#  [*server*]          - Server where connection requests originate (usually st2 server) (default: false)
#
# === Variables
#  [*default_ssh_public_key*]  - Default SSH Public Key without leading key-type and end email
#  [*default_ssh_key_type*]    - Default SSH Key (ssh-dsa/ssh-rsa)
#  [*default_ssh_private_key*] - Default Private Key
#  [*_ssh_public_key*]         - Local variable holding the real value of `ssh_public_key` (set or default)
#  [*_ssh_key_type*]           - Local variable holding the real value of `ssh_key_type` (set or default)
#  [*_ssh_private_key*]        - Local variable holding the real value of `ssh_private_key` (set or default)
#
# === Examples
#
#  include ::st2::stanley
#
class st2::stanley (
  $ssh_public_key  = undef,
  $ssh_key_type    = undef,
  $ssh_private_key = undef,
  $client          = true,
  $server          = true,
) {
  ### Defaults ###
  $default_ssh_public_key  = "AAAAB3NzaC1yc2EAAAADAQABAAABAQC4kFg0ZNmdrSqFvP+kZbVDlOdxzKgkcg3tKT19JTAKljpQCqUcZAEIthp8KsesXmAErZ8ykOEuYRCjug4Wd9uyXeewg5SgJy2gz/0biCAToJ71XxrPMM5SgVk/0sWxRIbmkU7+gNga6OIcimNxH5flESRAQx+C1kD1sBMfPeJzMa48kZWKBpaScguWka1N1rVn7nDza7srqPn+7NmQDVF/+VkMOxCEJcbIXdc0hYzebatWklYIcoSuF0WETYJxmKCoL8stTFucCxDXzbPvwGL5WctdZKcu7MeAaodH8V3x7aCujXzsSILtU7mc7uewuM2iT3nukLqYOk6W4UFRBk8n"
  $default_ssh_key_type    = 'ssh-rsa'
  $default_ssh_private_key = "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAuJBYNGTZna0qhbz/pGW1Q5TnccyoJHIN7Sk9fSUwCpY6UAql\nHGQBCLYafCrHrF5gBK2fMpDhLmEQo7oOFnfbsl3nsIOUoCctoM/9G4ggE6Ce9V8a\nzzDOUoFZP9LFsUSG5pFO/oDYGujiHIpjcR+X5REkQEMfgtZA9bATHz3iczGuPJGV\nigaWknILlpGtTda1Z+5w82u7K6j5/uzZkA1Rf/lZDDsQhCXGyF3XNIWM3m2rVpJW\nCHKErhdFhE2CcZigqC/LLUxbnAsQ182z78Bi+VnLXWSnLuzHgGqHR/Fd8e2gro18\n7EiC7VO5nO7nsLjNok957pC6mDpOluFBUQZPJwIDAQABAoIBAHVoDVQ3G1/8emJd\nGlqgALEfFiQERqn4i/dkFqN3dpoleq7UNrhavXWnMi3uoNp7pqUTNYRbOYPhZ05f\n2vpcALv0lKBq8671fUchSCetbopN0RDSESHgMD+33OiG0g+0QgSGRzQLDm3/22bA\negXKTTwArYjbqj32wZgJDAEBwv33dckJLVEqnq1o54XNZpCGXw8LUJTlNCwWVzoA\nS+/nKClV333x6x5UZnyc4N3iUS4//T25lDLWXHCwGBQyOFIvqS1fzDa9/9qGKpns\nfqAnXxvZwMHat008cQcWgJ9ripLVO2aG8+slR1JL3qNgNBLAKOnVe8akLMW+azOn\nvGlsz+ECgYEA4wrNySwHRdlmd9s9y9QwIEA66Lt8QDRRoW5Kd6eJMTGpbz7ffnF2\nFw6Zy6JOSyi5p8PfiD0H5A1EqrboFoF50jJ5rmG6IwtUJFbWLrN1zaREDta2xuFQ\nfmtPxkXNOK9RkdW1m4j1cXpF9F1QylIzhvkkp45d4lOPWvc3oBpePmkCgYEA0BqS\neaOxbe1aZD+jiKu9WrmfkLc7Ch6KFV9ziuno0ZfZ740FQJk3diVBC7B0/MKUMlqF\nAg98wkKAGGyVDpMKtMkxRSXMnTGPbuEuyDmdM/XKVsE9JAJgvrbDiQHFkZPQRqEf\nJSFLN7hTBJyIDIakQEZQZ4d8eUY1OBDgZA8Ejw8CgYAyX/pK0W8Hq3XV0BpE+F55\nOWcYrkiiQjl+dOcm51BETv2GBlA2UNxfv0iWavuuJ2oR9B7LrqbqjZsXuZ+DJtUt\nsy9WZq6TCfdwXKgHEqBnsTO8ix1gwStH8W1w05n2IsgZcG5sBRZYSEXvMykyysxN\n/UeJucfQ6LNc/o8kAdW5SQKBgC5q3uUW6AqW+KSHtVhUxkWoRbknxZl6Ol6ODd2c\nUvv9HPVbxSIlisNlh96tm0qNtDSPED/naHKEFsJb5dt8XNT6U20TA1LErTOUMrUi\ndLgUSO+U5qhTh3TCm1bB+GmCSOCYK7RCet6Q1KOgro/ssFJN3L1a8R6z1EcPLJ3k\n46VtAoGAQcW0Ip7+8zrvQbHp3uLAjJskhYZTAKDI/REKrhdsL22OTF6H4lOObGPL\n8Ph7hy2BqJOtuzSoYfHl5Kci4/qcJ5TBYItrxYPo/JVxcB25xtSRCv7rtfpJuC2O\nq5MwK3rNIoQ1EBTc7DVIVm9WV11Py3x7FfZb4eQzhFPZFQsV9n0=\n-----END RSA PRIVATE KEY-----"

  # Provide sane defaults for trial purposes
  if $ssh_public_key { $_ssh_public_key = $ssh_public_key }
    else { $_ssh_public_key = $default_ssh_public_key }
  if $ssh_key_type { $_ssh_key_type = $ssh_key_type }
    else { $_ssh_key_type = $default_ssh_key_type }
  if $ssh_private_key { $_ssh_private_key = $ssh_private_key }
    else { $_ssh_private_key = $default_ssh_private_key }

  if !$ssh_public_key or !$ssh_private_key {
    notify { '[st2::stanley] WARNING: this class has been setup with insecure default keys for testing purposes. Please refer to Class[st2] to learn more on configuring this for production use': }
  }

  st2::user { 'stanley':
    client            => $client,
    server            => $server,
    create_sudo_entry => true,
    ssh_public_key    => $_ssh_public_key,
    ssh_key_type      => $_ssh_key_type,
    ssh_private_key   => $_ssh_private_key,
  }

}
