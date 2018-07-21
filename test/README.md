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


## Running inspect against an existing container (if kitchen failed)

``` shell
export BUNDLE_GEMFILE=build/kitchen/Gemfile
bundle config --local path build/kitchen/vendor/cache
bundle install
bundle exec inspec exec --sudo --sudo-command="sudo -i" -i .kitchen/docker_id_rsa -t ssh://kitchen@localhost:32769 test/integration/2-stackstorm
```

``` shell
export KITCHEN_PORT=$(grep 'port:' .kitchen/default-ubuntu16.yml | awk '{print $2}')
bundle exec inspec exec --sudo --sudo-command="sudo -i" -i .kitchen/docker_id_rsa -t ssh://kitchen@localhost:$KITCHEN_PORT test/integration/2-stackstorm/
```

ssh -oPort=32769 -i .kitchen/docker_id_rsa kitchen@localhost

scp -r -oPort=32769 -i .kitchen/docker_id_rsa manifests/* kitchen@localhost:/tmp/kitchen/manifests/


export MANIFESTDIR='/tmp/kitchen/manifests'; sudo -E puppet apply /tmp/kitchen/manifests/test/fullinstall.pp --modulepath=/tmp/kitchen/modules --fileserverconfig=/tmp/kitchen/fileserver.conf      --detailed-exitcodes
