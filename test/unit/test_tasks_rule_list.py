from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from rule_list import St2RuleList


class St2RuleListTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = St2RuleList()
        self.assertIsInstance(task, St2TaskBase)

    @mock.patch('rule_list.St2RuleList.exec_cmd')
    def test_task_impl(self, mock_exec_cmd):
        args = {}
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = St2RuleList()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'rule', 'list', '--json'],
                                         'list rules')

    @mock.patch('rule_list.St2RuleList.exec_cmd')
    def test_task_impl_with_pack(self, mock_exec_cmd):
        args = {
            'pack': 'pack1',
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = St2RuleList()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'rule', 'list', '--json', '--pack', 'pack1'],
                                         'list rules')
