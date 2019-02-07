#!/usr/bin/env python
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class PackList(St2TaskBase):

    def task_impl(self, args):
        # get a list of packs
        cmd = ['st2', 'pack', 'list', '--json']
        return self.exec_cmd(cmd, 'list packs')


if __name__ == '__main__':
    PackList().run()
