#!/usr/bin/env python
#
# Testing:
#  # need to create a symlink because puppet-st2 doesn't match the module name
#  ln -s ~/src/git/puppet-st2 ~/tmp/bolt/st2
#  bolt task run --modulepath ~/tmp/bolt/ st2::pack_install pack="git" username="st2admin" password="xxx" --noop --nodes stackstorm.domain.tld --no-host-key-check
#
import json
import os
import re
import subprocess
import sys
import tempfile
import traceback

try:
    # python 2
    from urlparse import urlparse
except ImportError:
    # python 3
    from urllib.parse import urlparse

# try to find a [ or { at the start of a line
JSON_START_PATTERN = re.compile('^(\[|{).*$', re.MULTILINE)


class St2Base(object):

    def __init__(self, **kwargs):
        self.params = dict(**kwargs)
        self.api_key = self.params.get('api_key')
        self.auth_token = self.params.get('auth_token')
        self.username = self.params.get('username')
        self.password = self.params.get('password')
        # inherit environment variables from the Bolt context to preserve things
        # like locale... otherwise we get errors from the StackStorm client.
        self.env = os.environ

    def _make_error(self, msg, details = None):
        if details is None:
            details = {}
        error = {
            "_error": {
                "kind": "file_error",
                "msg": msg,
                "details": details,
            }
        }
        return error

    def login(self):
        # prefer API key over auth tokens
        if self.api_key:
            self.env['ST2_API_KEY'] = self.api_key
        elif self.auth_token:
            self.env['ST2_AUTH_TOKEN'] = self.auth_token
        elif self.username and self.password:
            # auth on the command line with username/password
            cmd = ['st2', 'auth', '--only-token', '-p', password, username]
            stdout = subprocess.check_output(cmd)
            self.env['ST2_AUTH_TOKEN'] = stdout.rstrip()
        # else
        #    assume auth token is written in client config for this user.
        #    don't worry, if there is no auth we'll get an error

    def _scan_for_json(self, stdout):
        # the output from st2 pack install doesn't print out in pure JSON, so
        # look for the JSON in the output
        start_pos = 0
        stdout_json = None
        while start_pos < len(stdout):
            # try to find the start of JSON
            m = JSON_START_PATTERN.search(stdout[start_pos:])
            if m:
                # we found some json potentially, get the position of the match
                # in the string and increment our start position that much
                start_pos += m.span(0)[0]
                try:
                    # try to parse JSON starting at the position of our JSON
                    # character match
                    stdout_json = json.loads(stdout[start_pos:])
                    break
                except:
                    # JSON parse failed, so start looking for JSON data beginning
                    # at the next character
                    start_pos += 1
                    pass
            else:
                # didn't find a patch in the entire string, bail out
                break

        # if we found JSON, return the parse result
        # else return the raw stdout
        if stdout_json:
            return {'result': stdout_json}
        else:
            return {'result': stdout}

    def _exec_cmd(self, cmd, error_msg):
        exitcode = 0
        result = {}
        try:
            stdout = subprocess.check_output(cmd,
                                             stderr=subprocess.STDOUT,
                                             env=self.env)
            result.update(self._scan_for_json(stdout))
        except subprocess.CalledProcessError as e:
            exitcode = 1
            tb = traceback.format_exc()
            result = self._make_error("Could not {}: {} \n {}\n {}".format(error_msg, str(e), e.output, tb))
        except Exception as e:
            exitcode = 1
            tb = traceback.format_exc()
            result = self._make_error("Could not {}: {}\n {}".format(error_msg, str(e), tb))
        return result, exitcode

    def run(self):
        raise RuntimeError("Not implement for base class St2Common")


class KeyGet(St2Base):

    def run(self):
        key = self.params['key']
        scope = self.params.get('scope')
        decrypt = self.params.get('decrypt')
        convert = self.params.get('convert', True)

        # build command
        cmd = ['st2', 'key', 'get', '--json']
        if scope:
            cmd += ['--scope', scope]
        if decrypt:
            cmd += ['--decrypt']
        cmd += [key]

        # run command - st2 key get xxx
        result, exitcode = self._exec_cmd(cmd, 'get key')

        # convert value from a JSON string to dict/list/etc
        if convert and result.get('result', {}).get('value'):
            try:
                parsed = json.loads(result['result']['value'])
                result['result']['value'] = parsed
            except:
                pass
        return result, exitcode


class KeyLoad(St2Base):

    def run(self):
        temp_fd = None
        temp_path = None
        try:
            keys = self.params['keys']
            convert = self.params.get('convert')

            # write our keys to a temporary file
            temp_fd, temp_path = tempfile.mkstemp(suffix='.json')
            with os.fdopen(temp_fd, 'w') as temp_file:
                temp_file.write(json.dumps(keys))

            # st2 key load from temp file
            cmd = ['st2', 'key', 'load', '--json']
            if convert:
                cmd += ['--convert']

            # run
            return self._exec_cmd(cmd, 'load keys')
        finally:
            if temp_path:
                os.remove(temp_path)


class PackInstall(St2Base):

    def run(self):
        # install the list of packs
        packs = self.params['packs']
        cmd = ['st2', 'pack', 'install', '--json'] + packs
        return self._exec_cmd(cmd, 'install packs')


class PackRemove(St2Base):

    def run(self):
        # remove the list of packs
        packs = self.params['packs']
        cmd = ['st2', 'pack', 'remove', '--json'] + packs
        return self._exec_cmd(cmd, 'remove packs')


if __name__ == '__main__':
    # read JSON data form stdin
    stdin_dict = json.load(sys.stdin)

    # create our client depending on the task name
    task = stdin_dict['_task']
    impl = None
    if task == 'st2::key_get':
        impl = KeyGet(**stdin_dict)
    elif task == 'st2::key_load':
        impl = KeyLoad(**stdin_dict)
    elif task == 'st2::pack_install':
        impl = PackInstall(**stdin_dict)
    elif task == 'st2::pack_remove':
        impl = PackRemove(**stdin_dict)
    else:
        raise ValueError("Unknown task name: {}".format(task))

    # login, then run the action
    impl.login()
    result, exitcode = impl.run()

    # convert result dict to JSON and exit
    print(json.dumps(result))
    exit(exitcode)
