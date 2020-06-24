#!/usr/bin/env python
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class St2Run(St2TaskBase):

    def task_impl(self, args):
        # Run a StackStorm action
        action = args['action']
        cmd = ['st2', 'run', '--json', action]

        # add in parametrs if they were passed
        parameters = args.get('parameters', None)
        if parameters:
            cmd += parameters
        return self.exec_cmd(cmd, 'run action')


if __name__ == '__main__':
    St2Run().run()
