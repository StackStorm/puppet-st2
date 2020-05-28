from test.unit.st2_test_case import St2TestCase
import mock
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))
from key_get import KeyGet


class KeyGetTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = KeyGet()
        self.assertIsInstance(task, St2TaskBase)

    def test_convert_result_from_json(self):
        res = {'result': {'value': '{"a": "b"}'}}
        convert = True
        task = KeyGet()
        result = task.convert_result_from_json(res, convert)
        self.assertEquals(result, {'result': {'value': {"a": "b"}}})

    def test_convert_result_from_json_false(self):
        res = {'result': {'value': '{"a": "b"}'}}
        convert = False
        task = KeyGet()
        result = task.convert_result_from_json(res, convert)
        self.assertEquals(result, {'result': {'value': '{"a": "b"}'}})

    def test_convert_result_from_json_invalid_json(self):
        res = {'result': {'value': '{"a": "b'}}
        convert = True
        task = KeyGet()
        result = task.convert_result_from_json(res, convert)
        self.assertEquals(result, {'result': {'value': '{"a": "b'}})

    def test_convert_result_from_json_no_value(self):
        res = {'result': {'blah': 'xxx'}}
        convert = True
        task = KeyGet()
        result = task.convert_result_from_json(res, convert)
        self.assertEquals(result, {'result': {'blah': 'xxx'}})

    def test_convert_result_from_json_result_string_no_value(self):
        res = {'result': 'string with non-json data'}
        convert = True
        task = KeyGet()
        result = task.convert_result_from_json(res, convert)
        self.assertEquals(result, {'result': 'string with non-json data'})

    def test_convert_result_from_json_no_result(self):
        res = {'value': '["a", "b", "c"]'}
        convert = True
        task = KeyGet()
        result = task.convert_result_from_json(res, convert)
        self.assertEquals(result, {'value': '["a", "b", "c"]'})

    @mock.patch('key_get.KeyGet.exec_cmd')
    def test_task_impl(self, mock_exec_cmd):
        args = {
            'key': 'test_key',
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = KeyGet()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'key', 'get', '--json', 'test_key'],
                                         'get key')

    @mock.patch('key_get.KeyGet.exec_cmd')
    def test_task_impl_scope(self, mock_exec_cmd):
        args = {
            'key': 'test_key',
            'scope': 'user',
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = KeyGet()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'key', 'get', '--json', '--scope', 'user',
                                          'test_key'],
                                         'get key')

    @mock.patch('key_get.KeyGet.exec_cmd')
    def test_task_impl_decrypt(self, mock_exec_cmd):
        args = {
            'key': 'test_key',
            'decrypt': False,
        }
        mock_exec_cmd.return_value = {'result': {'value': 'expected'}}

        # run
        task = KeyGet()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': 'expected'}})
        mock_exec_cmd.assert_called_with(['st2', 'key', 'get', '--json', 'test_key'],
                                         'get key')

    @mock.patch('key_get.KeyGet.exec_cmd')
    def test_task_impl_convert(self, mock_exec_cmd):
        args = {
            'key': 'test_key',
            'convert': True,
        }
        mock_exec_cmd.return_value = {'result': {'value': '["a", "b", "c"]'}}

        # run
        task = KeyGet()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': ["a", "b", "c"]}})
        mock_exec_cmd.assert_called_with(['st2', 'key', 'get', '--json', 'test_key'],
                                         'get key')

    @mock.patch('key_get.KeyGet.exec_cmd')
    def test_task_impl_convert_false(self, mock_exec_cmd):
        args = {
            'key': 'test_key',
            'convert': False,
        }
        mock_exec_cmd.return_value = {'result': {'value': '["a", "b", "c"]'}}

        # run
        task = KeyGet()
        result = task.task(args)

        # assert
        self.assertEquals(result, {'result': {'value': '["a", "b", "c"]'}})
        mock_exec_cmd.assert_called_with(['st2', 'key', 'get', '--json', 'test_key'],
                                         'get key')
