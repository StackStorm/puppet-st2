from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from pack_list import St2PackList


class St2PackListTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = St2PackList()
        self.assertIsInstance(task, St2TaskBase)

    @mock.patch('pack_list.St2PackList.exec_cmd')
    def test_task_impl(self, mock_exec_cmd):
        args = {}
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = St2PackList()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'pack', 'list', '--json'],
                                         'list packs')
