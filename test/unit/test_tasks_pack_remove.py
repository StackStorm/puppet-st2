from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from pack_remove import PackRemove


class PackRemoveTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = PackRemove()
        self.assertIsInstance(task, St2TaskBase)

    @mock.patch('pack_remove.PackRemove.exec_cmd')
    def test_task_impl(self, mock_exec_cmd):
        args = {
            'packs': ['pack1', 'pack2'],
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = PackRemove()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'pack', 'remove', '--json', 'pack1', 'pack2'],
                                         'remove packs')
