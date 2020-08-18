require 'json'

module FactHelper
  def self.ubuntu_trusty_x64
    facts = <<-EOF
{
  "kernelrelease": "3.13.0-36-generic",
  "kernel": "Linux",
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
EOF
    JSON.parse(facts)
  end
end
