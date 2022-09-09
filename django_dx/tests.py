from django.core.cache import caches
from django.db import connections
from django.test import TestCase


class DjangoDxTestCase(TestCase):
    def test_database_connection(self):
        default_connection = connections['default']
        cursor = default_connection.cursor()
        self.assertIsNotNone(cursor)

    def test_cache_backend_connection(self):
        connection = caches.create_connection("default")
        self.assertIsNotNone(connection)
