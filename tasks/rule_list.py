#!/usr/bin/env python
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class St2RuleList(St2TaskBase):

    def task_impl(self, args):
        cmd = ['st2', 'rule', 'list', '--json']

        # add in pack argument if it was passed
        pack = args.get('pack', None)
        if pack:
            cmd += ['--pack', pack]
        return self.exec_cmd(cmd, 'list rules')


if __name__ == '__main__':
    St2RuleList().run()
