from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from rule_disable import St2RuleDisable


class St2RuleDisableTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = St2RuleDisable()
        self.assertIsInstance(task, St2TaskBase)

    @mock.patch('rule_disable.St2RuleDisable.exec_cmd')
    def test_task_impl(self, mock_exec_cmd):
        args = {
            'rule': 'rule1',
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = St2RuleDisable()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'rule', 'disable', '--json', 'rule1'],
                                         'disable pack rules')
