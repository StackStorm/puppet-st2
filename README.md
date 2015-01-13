# st2

Module to manage [StackStorm](http://stackstorm.com)

## Maintainers

* James Fryman <james@stackstorm.com>
* Patrick Hoolboom <patrick@stackstorm.com>

## Quick Start

For a full installation on a single node, a profile already exists to
get you setup and going with minimal effort. Simply:

```
include ::st2::profile::fullinstall
```

## Configuration

This module aims to provide sane default configurations, but also stay
out of your way in the event you need something more custom. To accomplish
this, this module uses the Roles/Profiles pattern.


