from test.unit.st2_test_case import St2TestCase
import copy
import mock
import os
import subprocess
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'files'))
from st2_task_base import St2TaskBase

sys.path.append(os.path.join(os.environ['PT__installdir'], 'python_task_helper', 'files'))
from task_helper import TaskHelper, TaskError


class St2TaskHelperTestCase(St2TestCase):
    __test__ = True

    def expected_env(self, **kwargs):
        env = copy.deepcopy(os.environ)
        env.update(kwargs)
        env['LC_ALL'] = 'en_US.UTF-8'
        return env

    def test_init(self):
        task = St2TaskBase()
        self.assertIsInstance(task, TaskHelper)

    def test_login_no_args(self):
        args = {}
        env = self.expected_env()

        # run
        task = St2TaskBase()
        task.login(args)

        # assert
        self.assertEquals(task.env, env)

    def test_login_api_key(self):
        args = {
            'api_key': 'xyz123',
            'auth_token': '1234567890',
            'username': 'st2admin',
            'password': 'pass',
        }
        env = self.expected_env(ST2_API_KEY='xyz123')

        # run
        task = St2TaskBase()
        task.login(args)

        # assert
        self.assertEquals(task.env, env)
        self.assertEquals(task.api_key, 'xyz123')

    def test_login_auth_token(self):
        args = {
            'auth_token': '1234567890',
            'username': 'st2admin',
            'password': 'pass',
        }
        env = self.expected_env(ST2_AUTH_TOKEN='1234567890')

        # run
        task = St2TaskBase()
        task.login(args)

        # assert
        self.assertEquals(task.env, env)
        self.assertEquals(task.auth_token, '1234567890')

    @mock.patch('subprocess.check_output')
    def test_login_username_password(self, mock_subprocess):
        args = {
            'username': 'st2admin',
            'password': 'pass',
        }
        env = self.expected_env(ST2_AUTH_TOKEN='1234')
        mock_subprocess.return_value = '1234'

        # run
        task = St2TaskBase()
        task.login(args)

        # assert
        self.assertEquals(task.env, env)
        self.assertEquals(task.username, 'st2admin')
        self.assertEquals(task.password, 'pass')

    def test_parse_output_none(self):
        task = St2TaskBase()
        result = task.parse_output('\n\nblah')
        self.assertEquals(result, {'result': '\n\nblah'})

    def test_parse_output_list_begin(self):
        task = St2TaskBase()
        result = task.parse_output('["a", "b", "c"]')
        self.assertEquals(result, {'result': ['a', 'b', 'c']})

    def test_parse_output_list_middle(self):
        task = St2TaskBase()
        result = task.parse_output('\n\nblah["a", "b", "c"]')
        self.assertEquals(result, {'result': '\n\nblah["a", "b", "c"]'})

    def test_parse_output_list_invalid(self):
        task = St2TaskBase()
        result = task.parse_output('["a", "b"')
        self.assertEquals(result, {'result': '["a", "b"'})

    def test_parse_output_dict_begin(self):
        task = St2TaskBase()
        result = task.parse_output('{"a":"b"}')
        self.assertEquals(result, {'result': {'a': 'b'}})

    def test_parse_output_dict_middle(self):
        task = St2TaskBase()
        result = task.parse_output('\n\nblah{"a": "b"}')
        self.assertEquals(result, {'result': '\n\nblah{"a": "b"}'})

    def test_parse_output_dict_invalid(self):
        task = St2TaskBase()
        result = task.parse_output('{"a": "b"')
        self.assertEquals(result, {'result': '{"a": "b"'})

    @mock.patch('subprocess.check_output')
    def test_exec_cmd(self, mock_subprocess):
        cmd = ['ls', '-l']
        mock_subprocess.return_value = 'blah'

        # run
        task = St2TaskBase()
        task.login({'api_key': 'abc123'})
        result = task.exec_cmd(cmd, 'list files')

        # assert
        self.assertEquals(result, {'result': 'blah'})
        mock_subprocess.assert_called_with(['ls', '-l'],
                                           stderr=subprocess.STDOUT,
                                           env=self.expected_env(ST2_API_KEY='abc123'))

    @mock.patch('subprocess.check_output')
    def test_exec_cmd_json_output(self, mock_subprocess):
        cmd = ['ls', '-l']
        mock_subprocess.return_value = '{"this_is_a_key": "value"}'

        # run
        task = St2TaskBase()
        task.login({'api_key': 'abc123'})
        result = task.exec_cmd(cmd, 'list files')

        # assert
        self.assertEquals(result, {'result': {"this_is_a_key": "value"}})
        mock_subprocess.assert_called_with(['ls', '-l'],
                                           stderr=subprocess.STDOUT,
                                           env=self.expected_env(ST2_API_KEY='abc123'))

    @mock.patch('subprocess.check_output')
    def test_exec_cmd_subprocess_exception(self, mock_subprocess):
        cmd = ['ls', '-l']
        mock_subprocess.side_effect = subprocess.CalledProcessError(1, 'ls', output='blah')

        # run
        task = St2TaskBase()

        with self.assertRaises(TaskError):
            task.exec_cmd(cmd, 'list files')

    @mock.patch('subprocess.check_output')
    def test_exec_cmd_generic_exception(self, mock_subprocess):
        cmd = ['ls', '-l']
        mock_subprocess.side_effect = ValueError('blah')

        # run
        task = St2TaskBase()
        with self.assertRaises(TaskError):
            task.exec_cmd(cmd, 'list files')

    @mock.patch('st2_task_base.St2TaskBase.task_impl')
    def test_task(self, mock_task_impl):
        args = {
            'api_key': 'xyz123'
        }
        mock_task_impl.return_value = 'blah'
        env = self.expected_env(ST2_API_KEY='xyz123')

        # run
        task = St2TaskBase()
        result = task.task(args)

        # assert
        self.assertEquals(result, 'blah')
        self.assertEquals(task.api_key, 'xyz123')
        self.assertEquals(task.env, env)

    def test_task_default_raises(self):
        task = St2TaskBase()
        with self.assertRaises(TaskError):
            task.task({})

    def test_task_impl_raises(self):
        task = St2TaskBase()
        with self.assertRaises(NotImplementedError):
            task.task_impl({})
