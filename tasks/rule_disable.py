#!/usr/bin/env python
import os
import sys

# import Bolt task helper
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'files'))
from st2_task_base import St2TaskBase


class St2RuleDisable(St2TaskBase):

    def task_impl(self, args):
        # Disable the specified rule
        rule = args['rule']
        cmd = ['st2', 'rule', 'disable', '--json', rule]
        return self.exec_cmd(cmd, 'disable pack rules')


if __name__ == '__main__':
    St2RuleDisable().run()
