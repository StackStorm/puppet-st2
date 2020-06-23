#!/usr/bin/env python
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class St2PackRegister(St2TaskBase):

    def task_impl(self, args):
        # register a list of packs based on a paths on the filesystem
        paths = args['paths']
        cmd = ['st2', 'pack', 'register', '--json'] + paths
        return self.exec_cmd(cmd, 'register packs')


if __name__ == '__main__':
    St2PackRegister().run()
