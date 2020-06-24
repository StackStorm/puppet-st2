#!/usr/bin/env python
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class St2PackInstall(St2TaskBase):

    def task_impl(self, args):
        # install the list of packs
        packs = args['packs']
        cmd = ['st2', 'pack', 'install', '--json'] + packs
        return self.exec_cmd(cmd, 'install packs')


if __name__ == '__main__':
    St2PackInstall().run()
