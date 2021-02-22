#!/usr/bin/env python
import json
import os
import sys
import tempfile

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class St2KeyLoad(St2TaskBase):

    def task_impl(self, args):
        temp_fd = None
        temp_path = None
        try:
            keys = args['keys']
            convert = args.get('convert')

            # write our keys to a temporary file
            temp_fd, temp_path = tempfile.mkstemp(suffix='.json')
            with os.fdopen(temp_fd, 'w') as temp_file:
                temp_file.write(json.dumps(keys))

            # st2 key load from temp file
            cmd = ['st2', 'key', 'load', '--json']
            if convert:
                cmd += ['--convert']
            cmd += [temp_path]

            # run
            return self.exec_cmd(cmd, 'load keys')
        finally:
            if temp_path:
                os.remove(temp_path)


if __name__ == '__main__':
    St2KeyLoad().run()
