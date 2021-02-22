from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from pack_register import St2PackRegister


class St2PackRegisterTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = St2PackRegister()
        self.assertIsInstance(task, St2TaskBase)

    @mock.patch('pack_register.St2PackRegister.exec_cmd')
    def test_task_impl(self, mock_exec_cmd):
        args = {
            'paths': ['/home/user/pack1', '/home/blah/pack2'],
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = St2PackRegister()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'pack', 'register', '--json',
                                          '/home/user/pack1', '/home/blah/pack2'],
                                         'register packs')
