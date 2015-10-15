from resetpasswd import build_conn_args


def test_build_conn_args():
    expected_args = {'user': 'wendy', 'host': 'geonetwork.example.com', 'password': 'password', 'port': '5432', 'database': 'geonetwork'}
    postgres_url = 'jdbc:postgresql://geonetwork.example.com:5432/geonetwork'
    postgres_args = build_conn_args(postgres_url, 'wendy', 'password')
    assert cmp(postgres_args, expected_args) == 0
    postgis_url = 'jdbc:postgresql_postGIS://geonetwork.example.com:5432/geonetwork'
    postgis_args = build_conn_args(postgis_url, 'wendy', 'password')
    assert cmp(postgis_args, expected_args) == 0
