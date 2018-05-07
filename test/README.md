## Testing
This directory contains Integration tests, powered by [InSpec.io](https://www.inspec.io/) Infrastructure Testing framework.
They ensure that custom OS Linux-level modifications are in place and StackStorm was really deployed, works correctly and alive with other services it relies on like RabbitMQ, PostgreSQL, MongoDB.

For InSpec documentation see: 
- DSL: https://www.inspec.io/docs/reference/dsl_inspec/
- Resources: https://www.inspec.io/docs/reference/resources/

It's possible to run the integration test from specific file or directory: 
```
sudo inspec exec test/integration/<filename_or_dir>
```
This might be useful during development.

> Please don't forget to include respective tests for every new critical feature of the system!<br>
> See existing `/tests` examples which make it easy to add more tests.
