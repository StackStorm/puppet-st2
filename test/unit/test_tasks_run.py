from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from run import St2Run


class St2RunTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = St2Run()
        self.assertIsInstance(task, St2TaskBase)

    @mock.patch('run.St2Run.exec_cmd')
    def test_task_impl(self, mock_exec_cmd):
        args = {
            'action': 'pack1.action2',
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = St2Run()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'run', '--json', 'pack1.action2'],
                                         'run action')

    @mock.patch('run.St2Run.exec_cmd')
    def test_task_impl_with_parameters(self, mock_exec_cmd):
        args = {
            'action': 'pack1.action2',
            'parameters': [
                'cmd=date',
                'param2=value2',
                # this is how you pass a dict/object
                'param_dict={"key": "value"}',
            ],
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = St2Run()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'run', '--json', 'pack1.action2',
                                          'cmd=date',
                                          'param2=value2',
                                          'param_dict={"key": "value"}'],
                                         'run action')
