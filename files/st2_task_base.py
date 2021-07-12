#!/usr/bin/env python
import json
import os
import subprocess
import sys
import traceback

# import Bolt task helper
sys.path.append(os.path.join(os.environ['PT__installdir'], 'python_task_helper', 'files'))
from task_helper import TaskHelper, TaskError

try:
    # python 2
    from urlparse import urlparse
except ImportError:
    # python 3
    from urllib.parse import urlparse  # noqa


class St2TaskBase(TaskHelper):

    def login(self, args):
        self.api_key = args.get('api_key')
        self.auth_token = args.get('auth_token')
        self.username = args.get('username')
        self.password = args.get('password')
        # inherit environment variables from the Bolt context to preserve things
        # like locale... otherwise we get errors from the StackStorm client.
        self.env = os.environ
        # force the locale to UTF8, otherwise we get warnings from the stackstorm side
        # and result in us not being able to parse JSON output
        self.env['LC_ALL'] = 'en_US.UTF-8'

        # prefer API key over auth tokens
        if self.api_key:
            self.env['ST2_API_KEY'] = self.api_key
        elif self.auth_token:
            self.env['ST2_AUTH_TOKEN'] = self.auth_token
        elif self.username and self.password:
            # auth on the command line with username/password
            cmd = ['st2', 'auth', '--only-token', '-p', self.password, self.username]
            stdout = self.bytes_to_string(subprocess.check_output(cmd))
            self.env['ST2_AUTH_TOKEN'] = stdout.rstrip()
        # else
        #    assume auth token is written in client config for this user.
        #    don't worry, if there is no auth we'll get an error

    def bytes_to_string(self, string):
        if isinstance(string, bytes):
            string = string.decode("utf-8")

        return string

    def parse_output(self, stdout):
        print(stdout)
        try:
            stdout = self.bytes_to_string(stdout)
            print(stdout)
            # try to parse stdout as JSON and return the parse result
            return {'result': json.loads(stdout)}
        except (ValueError, TypeError):
            # JSON parsing failed, return the raw stdout string
            return {'result': stdout}

    def exec_cmd(self, cmd, error_msg):
        result = {}
        try:
            stdout = subprocess.check_output(cmd,
                                             stderr=self.parse_output(subprocess.STDOUT),
                                             env=self.env)
            result.update(self.parse_output(stdout))
        except subprocess.CalledProcessError as e:
            tb = traceback.format_exc()
            raise TaskError(("Could not {}: {} \n {}\n {}".
                             format(error_msg, str(e), e.output, tb)),
                            'st2.task.base/subprocess_error')
        except Exception as e:
            tb = traceback.format_exc()
            raise TaskError(("Could not {}: {}\n {}".
                             format(error_msg, str(e), tb)),
                            'st2.task.base/exec_exception')
        return result

    def task(self, args):
        try:
            self.login(args)
            return self.task_impl(args)
        except Exception as e:
            tb = traceback.format_exc()
            raise TaskError(str(e) + '\n' + tb,
                            'st2.task.base/task_exception')

    def task_impl(self, args):
        raise NotImplementedError()
