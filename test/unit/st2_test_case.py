import yaml
import json
import logging
import os
import inspect

from unittest2 import TestCase


class St2TestCase(TestCase):
    __test__ = False

    def setUp(self):
        super(St2TestCase, self).setUp()
        logging.disable(logging.CRITICAL)  # disable logging

    def tearDown(self):
        super(St2TestCase, self).tearDown()
        logging.disable(logging.NOTSET)  # enable logging

    def get_fixture_content(self, fixture_path):
        """
        Return raw fixture content for the provided fixture path.
        :param fixture_path: Fixture path relative to the tests/fixtures/ directory.
        :type fixture_path: ``str``
        """
        base_pack_path = self._get_base_pack_path()
        fixtures_path = os.path.join(base_pack_path, "tests/fixtures/")
        fixture_path = os.path.join(fixtures_path, fixture_path)

        with open(fixture_path, "r") as fp:
            content = fp.read()

        return content

    def _get_base_pack_path(self):
        test_file_path = inspect.getfile(self.__class__)
        base_pack_path = os.path.join(os.path.dirname(test_file_path), "..")
        base_pack_path = os.path.abspath(base_pack_path)
        return base_pack_path

    def load_yaml(self, filename):
        return yaml.safe_load(self.get_fixture_content(filename))

    def load_json(self, filename):
        return json.loads(self.get_fixture_content(filename))
