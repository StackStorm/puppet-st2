import yaml
import json
import logging

from unittest import TestCase


class St2TestCase(TestCase):
    __test__ = False

    def setUp(self):
        super(St2TestCase, self).setUp()
        logging.disable(logging.CRITICAL)  # disable logging

    def tearDown(self):
        super(St2TestCase, self).tearDown()
        logging.disable(logging.NOTSET)  # enable logging

    def load_yaml(self, filename):
        return yaml.safe_load(self.get_fixture_content(filename))

    def load_json(self, filename):
        return json.loads(self.get_fixture_content(filename))
