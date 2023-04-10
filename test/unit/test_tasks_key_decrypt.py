from test.unit.st2_test_case import St2TestCase
# import mock
import os
import sys
from key_decrypt import AESKey

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'tasks'))


class AESKeyTestCase(St2TestCase):
    __test__ = True

    def test_init(self):
        task = AESKey('test', 'test', 256)
        self.assertIsInstance(task, object)
