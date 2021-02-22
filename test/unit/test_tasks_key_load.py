from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from key_load import St2KeyLoad


class St2KeyLoadTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = St2KeyLoad()
        self.assertIsInstance(task, St2TaskBase)

    @mock.patch('os.remove')
    @mock.patch('os.fdopen')
    @mock.patch('tempfile.mkstemp')
    @mock.patch('key_load.St2KeyLoad.exec_cmd')
    def test_task_impl(self, mock_exec_cmd, mock_mkstemp, mock_fdopen, mock_remove):
        args = {
            'keys': [
                {
                    'name': 'key1',
                    'value': 'blah1'
                },
                {
                    'name': 'key2',
                    'value': 'blah2'
                },
            ]
        }
        mock_mkstemp.return_value = (123, '/tmp/xyz123.json')
        mock_temp_file = mock.MagicMock()
        mock_context_manager = mock.MagicMock()
        mock_context_manager.__enter__ = mock.MagicMock(return_value=mock_temp_file)
        mock_context_manager.__exit__ = mock.MagicMock(return_value=None)
        mock_fdopen.return_value = mock_context_manager
        mock_exec_cmd.return_value = 'expected'

        task = St2KeyLoad()
        result = task.task(args)

        self.assertEquals(result, 'expected')
        mock_mkstemp.assert_called_with(suffix='.json')
        mock_temp_file.write.assert_called_with(
            '[{"name": "key1", "value": "blah1"}, {"name": "key2", "value": "blah2"}]')
        mock_exec_cmd.assert_called_with(['st2', 'key', 'load', '--json', '/tmp/xyz123.json'],
                                         'load keys')
        mock_remove.assert_called_with('/tmp/xyz123.json')

    @mock.patch('os.remove')
    @mock.patch('os.fdopen')
    @mock.patch('tempfile.mkstemp')
    @mock.patch('key_load.St2KeyLoad.exec_cmd')
    def test_task_impl_convert(self, mock_exec_cmd, mock_mkstemp, mock_fdopen, mock_remove):
        args = {
            'keys': [
                {
                    'name': 'key1',
                    'value': 'blah1'
                },
                {
                    'name': 'key2',
                    'value': 'blah2'
                },
            ],
            'convert': True,
        }
        mock_mkstemp.return_value = (123, '/tmp/xyz123.json')
        mock_temp_file = mock.MagicMock()
        mock_context_manager = mock.MagicMock()
        mock_context_manager.__enter__ = mock.MagicMock(return_value=mock_temp_file)
        mock_context_manager.__exit__ = mock.MagicMock(return_value=None)
        mock_fdopen.return_value = mock_context_manager
        mock_exec_cmd.return_value = 'expected'

        task = St2KeyLoad()
        result = task.task(args)

        self.assertEquals(result, 'expected')
        mock_mkstemp.assert_called_with(suffix='.json')
        mock_temp_file.write.assert_called_with(
            '[{"name": "key1", "value": "blah1"}, {"name": "key2", "value": "blah2"}]')
        mock_exec_cmd.assert_called_with(['st2', 'key', 'load', '--json', '--convert',
                                          '/tmp/xyz123.json'],
                                         'load keys')
        mock_remove.assert_called_with('/tmp/xyz123.json')
