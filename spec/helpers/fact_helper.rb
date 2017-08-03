require 'json'

module FactHelper
  def self.ubuntu_trusty_x64
    facts = %q(
{
  "kernelrelease": "3.13.0-36-generic",
  "kernel": "Linux",
  "mistral_bootstrapped": "true",
  "role": "st2ops",
  "st2client_bootstrapped": "true",
  "st2server_bootstrapped": "true",
  "st2web_bootstrapped": "true",
  "virtual": "xenhvm",
  "is_virtual": "true",
  "ps": "ps -ef",
  "uptime_hours": 123,
  "interfaces": "eth0,lo",
  "ipaddress_eth0": "10.0.1.41",
  "macaddress_eth0": "06:cc:ca:50:17:98",
  "netmask_eth0": "255.255.255.0",
  "mtu_eth0": "9001",
  "ipaddress_lo": "127.0.0.1",
  "netmask_lo": "255.0.0.0",
  "mtu_lo": "65536",
  "operatingsystemrelease": "14.04",
  "timezone": "UTC",
  "lsbmajdistrelease": "14.04",
  "id": "root",
  "lsbdistid": "Ubuntu",
  "kernelversion": "3.13.0",
  "puppetversion": "3.7.3",
  "processors": {
    "models": [
      "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz",
      "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz",
      "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz",
      "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz"
    ],
    "count": 4,
    "physicalcount": 1
  },
  "architecture": "amd64",
  "hardwaremodel": "x86_64",
  "operatingsystem": "Ubuntu",
  "os": {
    "name": "Ubuntu",
    "family": "Debian",
    "release": {
      "major": "14.04",
      "full": "14.04"
    },
    "lsb": {
      "distcodename": "trusty",
      "distid": "Ubuntu",
      "distdescription": "Ubuntu 14.04.1 LTS",
      "distrelease": "14.04",
      "majdistrelease": "14.04"
    }
  },
  "processor0": "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz",
  "processor1": "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz",
  "processor2": "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz",
  "processor3": "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz",
  "processorcount": "4",
  "fqdn": "st2ops001.uswest2.stackstorm.net",
  "facterversion": "2.2.0",
  "gid": "root",
  "rubysitedir": "/usr/local/lib/site_ruby/1.9.1",
  "sshdsakey": "AAAAB3NzaC1kc3MAAACBANBIgxy7hA5uL1ukyf12E2FSUlqBYwkEqz01EUX7dghui518Hw9AoEymGD04NWM02ah4RBTBz93Ch4w3Qxc4f+1+xxaOkg9gZnmN/owOCVud25vXbf6F+gBSMy+HGTnSil+F2ODxTmmTuk6lQ+/UixjqaB+8EqI4Ncti/9dWnUQzAAAAFQCmJxEGyC3X0v2WS0O9BiIf1ilGowAAAIEAv6ow+N+/0MXFDdSgTJpLQIXyPq7U2MJZQk17Q3a7UieDMyCbke1BhuPvVI3HZuZOOu8pIVsKmvrjszNuypY5W861qV9BX/VONUHJNYoaosO8Z/lmFRp/Lrq9RKhKYnSDWYkIulSWqydE9Ux6gp3prS3ia1qud1E1mJwCX/MLbG4AAACBAMvZE85mcdCl635+TCRugU1+PY4lN8ajg5WJIVymuWKZtH1ehRIaIko1f8gPdt9RE79Nkmq09NZQmMyeM8OvqS3X00GlspzGrkkZYbw9xBs9NRmbukppR8VKZmwaHCet8G3xMcOszopNb53pxGdUD8LJ4Fj3JWOEf60oaNjsU8XH",
  "sshfp_dsa": "SSHFP 2 1 692239d14c8dbb547fa0ab632eb91118e138d205\nSSHFP 2 2 84b2980d6681faad82c66d7a22ecce434d414812d970cef146989f2fb253e70d",
  "sshrsakey": "AAAAB3NzaC1yc2EAAAADAQABAAABAQC2ef8NZmCZEh3yHSHqRMnKTLO7YXqr+ts58VTA42ATd4XWc/kvbnxnuecjMWTSROVvxIcvl3oVZYOz5M8sk5ZLqcZKvhPKI/0UCbgDi/CzvZsJFcYNL5Qtfx28g11+naieAALlYEn4wjUT6MTsinuUBm9CwaR/g1DatReNW6SjTCDL4qBV91NvCMAPvPdK/sQ0phlnO5TQxqrSCMC069KuNahyVDnYN7nX/YxQGlikZ4qfMgv7+KgO3ToqoCVhDri0vJEsT3LDd6UERCpu+t87xAj2I/j2p0IYTQOiAHl8dbVJUacYvGSAaraBf0FwgTDQK62XGdyCNM3k5e0mQXLl",
  "sshfp_rsa": "SSHFP 1 1 1d484070b0745886a9387463b5e5eecfb6c03b9d\nSSHFP 1 2 09d9ffbefca6415131a1fa513d2d12f01f315528e196b3c0d8e42294ff846f3f",
  "sshecdsakey": "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLaGfqlpNfoLIohQnFu486BE0B8c5DdXlegNWlSq+U4MGSygJkejH2R5N8QY3osPidYYNKcaWprf4ztWfTJU9XQ=",
  "sshfp_ecdsa": "SSHFP 3 1 e147ff9f2a1b2824d25af3b58e0c14c8d4a7e86c\nSSHFP 3 2 764d146ac2bc794d30dfc8c54a6a910033057f02f6758487d9d5b11f997b9063",
  "rubyversion": "1.9.3",
  "uptime_days": 5,
  "lsbdistcodename": "trusty",
  "uptime_seconds": 444736,
  "hardwareisa": "x86_64",
  "filesystems": "btrfs,ext2,ext3,ext4,hfs,hfsplus,iso9660,jfs,minix,msdos,ntfs,qnx4,ufs,vfat,xfs",
  "path": "/opt/puppet/vendor/bundle/ruby/1.9.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  "osfamily": "Debian",
  "partitions": {
    "xvda1": {
      "uuid": "d36a9e2f-dae9-477f-8aea-29f1bdd1c04e",
      "size": "16755795",
      "mount": "/",
      "filesystem": "ext4"
    }
  },
  "netmask": "255.255.255.0",
  "ipaddress": "10.0.1.41",
  "physicalprocessorcount": "1",
  "uniqueid": "007f0100",
  "operatingsystemmajrelease": "14.04",
  "blockdevice_xvda_size": 8589934592,
  "blockdevice_xvdf_size": 107374182400,
  "blockdevice_xvdg_size": 107374182400,
  "blockdevices": "xvda,xvdf,xvdg",
  "domain": "uswest2.stackstorm.net",
  "ec2_metadata": {
    "ami-id": "ami-3d50120d",
    "ami-launch-index": "0",
    "ami-manifest-path": "(unknown)",
    "block-device-mapping": {
      "ami": "/dev/sda1",
      "ephemeral0": "sdb",
      "ephemeral1": "sdc",
      "root": "/dev/sda1"
    },
    "hostname": "ip-10-0-1-41.uswest2.stackstorm.net stackstorm.net",
    "instance-action": "none",
    "instance-id": "i-c869e93e",
    "instance-type": "c4.xlarge",
    "local-hostname": "ip-10-0-1-41.uswest2.stackstorm.net stackstorm.net",
    "local-ipv4": "10.0.1.41",
    "mac": "06:cc:ca:50:17:98",
    "metrics": {
      "vhostmd": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    },
    "network": {
      "interfaces": {
        "macs": {
          "06:cc:ca:50:17:98": {
            "device-number": "0",
            "interface-id": "eni-45e5c033",
            "local-hostname": "ip-10-0-1-41.uswest2.stackstorm.net stackstorm.net",
            "local-ipv4s": "10.0.1.41",
            "mac": "06:cc:ca:50:17:98",
            "owner-id": "053075847820",
            "security-group-ids": "sg-aa365ccf",
            "security-groups": "default",
            "subnet-id": "subnet-4e73bc39",
            "subnet-ipv4-cidr-block": "10.0.1.0/24",
            "vpc-id": "vpc-754e9d10",
            "vpc-ipv4-cidr-block": "10.0.0.0/16"
          }
        }
      }
    },
    "placement": {
      "availability-zone": "us-west-2b"
    },
    "profile": "default-hvm",
    "public-keys": {
      "0": {
        "openssh-key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqwdPt1Evue50djK1XRJn0rnB5eKtqYyF4qZD+uUifECD9ziR8DxW2mdS6oF6mHhnXPLp7plmGnjxrWN4BnlWgL62Zb5ByuCCiyPd4+frqQqhha2FekxjNpBhayChvlE8jppYpsTpjqZij37wLZNpEaMcJHpO06Z81VvsIMi9jIhryI0oY+i+KDJuVKxNFD6X6NW6mkcDR/h24x/Fe9kEqr4DrXdQXIy/Z8sZX8tXdPx5LtBPzazXRd0HM69k7OPiaAaWRQh3By1Koje1nTZi/W1EgQV+mCQlp/TqWuko1t9AjWdl35/iUICpfQeOOeVd6N84gGJc8KrOgsj95vZVR st2_deploy"
      }
    },
    "reservation-id": "r-62395b6e",
    "security-groups": "default",
    "services": {
      "domain": "amazonaws.com"
    }
  },
  "ec2_userdata": "#!/bin/bash\n\nSYSTEMUSER=\"stanley\"\n\ncreate_user() {\n\n  if [ $(id -u ${SYSTEMUSER} &> /devnull; echo $?) != 0 ]\n  then\n    echo \"########## Creating system user: ${SYSTEMUSER} ##########\"\n    groupadd -g 706 ${SYSTEMUSER}\n    useradd -u 706 -g 706 ${SYSTEMUSER}\n    mkdir -p /home/${SYSTEMUSER}/.ssh\n    curl -Ss -o /home/${SYSTEMUSER}/.ssh/authorized_keys https://gist.githubusercontent.com/DoriftoShoes/d729b0d769a56672a6cd/raw/ca17ed9d6fe25cab0c574a242557612925c4c0e2/stanley_rsa.pub\n    chmod 0700 /home/${SYSTEMUSER}/.ssh\n    chmod 0600 /home/${SYSTEMUSER}/.ssh/authorized_keys\n    chown -R ${SYSTEMUSER}:${SYSTEMUSER} /home/${SYSTEMUSER}\n    if [ $(grep 'stanley' /etc/sudoers.d/* &> /dev/null; echo $?) != 0 ]\n    then\n      echo \"${SYSTEMUSER}    ALL=(ALL)       NOPASSWD: ALL\" >> /etc/sudoers.d/st2\n    fi\n  fi\n}\n\ncreate_user\n",
  "ec2_ami_id": "ami-3d50120d",
  "ec2_ami_launch_index": "0",
  "ec2_ami_manifest_path": "(unknown)",
  "ec2_block_device_mapping_ami": "/dev/sda1",
  "ec2_block_device_mapping_ephemeral0": "sdb",
  "ec2_block_device_mapping_ephemeral1": "sdc",
  "ec2_block_device_mapping_root": "/dev/sda1",
  "ec2_hostname": "ip-10-0-1-41.uswest2.stackstorm.net stackstorm.net",
  "ec2_instance_action": "none",
  "ec2_instance_id": "i-c869e93e",
  "ec2_instance_type": "c4.xlarge",
  "ec2_local_hostname": "ip-10-0-1-41.uswest2.stackstorm.net stackstorm.net",
  "ec2_local_ipv4": "10.0.1.41",
  "ec2_mac": "06:cc:ca:50:17:98",
  "ec2_metrics_vhostmd": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_device_number": "0",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_interface_id": "eni-45e5c033",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_local_hostname": "ip-10-0-1-41.uswest2.stackstorm.net stackstorm.net",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_local_ipv4s": "10.0.1.41",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_mac": "06:cc:ca:50:17:98",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_owner_id": "053075847820",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_security_group_ids": "sg-aa365ccf",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_security_groups": "default",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_subnet_id": "subnet-4e73bc39",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_subnet_ipv4_cidr_block": "10.0.1.0/24",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_vpc_id": "vpc-754e9d10",
  "ec2_network_interfaces_macs_06:cc:ca:50:17:98_vpc_ipv4_cidr_block": "10.0.0.0/16",
  "ec2_placement_availability_zone": "us-west-2b",
  "ec2_profile": "default-hvm",
  "ec2_public_keys_0_openssh_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqwdPt1Evue50djK1XRJn0rnB5eKtqYyF4qZD+uUifECD9ziR8DxW2mdS6oF6mHhnXPLp7plmGnjxrWN4BnlWgL62Zb5ByuCCiyPd4+frqQqhha2FekxjNpBhayChvlE8jppYpsTpjqZij37wLZNpEaMcJHpO06Z81VvsIMi9jIhryI0oY+i+KDJuVKxNFD6X6NW6mkcDR/h24x/Fe9kEqr4DrXdQXIy/Z8sZX8tXdPx5LtBPzazXRd0HM69k7OPiaAaWRQh3By1Koje1nTZi/W1EgQV+mCQlp/TqWuko1t9AjWdl35/iUICpfQeOOeVd6N84gGJc8KrOgsj95vZVR st2_deploy",
  "ec2_reservation_id": "r-62395b6e",
  "ec2_security_groups": "default",
  "ec2_services_domain": "amazonaws.com",
  "lsbdistdescription": "Ubuntu 14.04.1 LTS",
  "system_uptime": {
    "seconds": 444736,
    "hours": 123,
    "days": 5,
    "uptime": "5 days"
  },
  "uptime": "5 days",
  "selinux": "false",
  "augeasversion": "1.2.0",
  "network_eth0": "10.0.1.0",
  "network_lo": "127.0.0.0",
  "memorysize": "7.30 GB",
  "memoryfree": "5.27 GB",
  "swapsize": "0.00 MB",
  "swapfree": "0.00 MB",
  "swapsize_mb": "0.00",
  "swapfree_mb": "0.00",
  "memorysize_mb": "7479.95",
  "memoryfree_mb": "5400.86",
  "bios_vendor": "Xen",
  "bios_version": "4.2.amazon",
  "bios_release_date": "05/06/2015",
  "manufacturer": "Xen",
  "productname": "HVM domU",
  "serialnumber": "ec241919-264a-7b95-60e8-83d6d386eeaf",
  "uuid": "EC241919-264A-7B95-60E8-83D6D386EEAF",
  "type": "Other",
  "lsbdistrelease": "14.04",
  "macaddress": "06:cc:ca:50:17:98",
  "hostname": "st2ops001",
  "kernelmajversion": "3.13"
}
)
    return JSON.parse(facts)
  end
end
