#!/usr/bin/env python
import json
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class KeyGet(St2TaskBase):

    def convert_result_from_json(self, result, convert):
        # convert value from a JSON string to dict/list/etc
        if convert and result.get('result', {}).get('value'):
            try:
                result['result']['value'] = json.loads(result['result']['value'])
            except ValueError:
                pass
        return result

    def task_impl(self, args):
        key = args['key']
        scope = args.get('scope')
        decrypt = args.get('decrypt')
        convert = args.get('convert', True)

        # build command
        cmd = ['st2', 'key', 'get', '--json']
        if scope:
            cmd += ['--scope', scope]
        if decrypt:
            cmd += ['--decrypt']
        cmd += [key]

        # run command - st2 key get xxx
        result = self.exec_cmd(cmd, 'get key')
        return self.convert_result_from_json(result, convert)


if __name__ == '__main__':
    KeyGet().run()
