#!/usr/bin/env bash

set -e

export PGPASSWORD='password'
export PGUSER='pguser'
export PGHOST='xxx.xx.xxx.xxx'

psql -d devtest -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'qgep_prod';"
psql -d devtest -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'qgep_comp';"
psql -d devtest -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'qgep_1_0';"



dropdb qgep_prod || true
createdb -T qgep_1_0 qgep_prod
psql -d qgep_prod -c"	ALTER TABLE qgep_sys.pum_info ADD CONSTRAINT pum_info_version_excl EXCLUDE USING btree ( version WITH =) WHERE (type = 0)"
psql -d qgep_prod -c"	ALTER TABLE qgep_sys.pum_info ALTER COLUMN version SET NOT NULL;"

dropdb qgep_test || true
createdb qgep_test

dropdb qgep_comp || true
createdb qgep_comp
cat qgep_v1.4.0_structure_with_value_lists.sql | grep -vw "idle_in_transaction_session_timeout" | psql -d qgep_comp -v ON_ERROR_STOP=1
psql -d qgep_comp -c"	ALTER FUNCTION qgep_import.manhole_quarantine_try_structure_update() OWNER TO sige;"

# supprimer les deltas qui concernent les vues (elles seront créées à la fin)
# utiliser la branche avec les deltas moidifiés
pushd datamodel
# TODO: git checkout migration_0_9_to_1_4_0

# -x to ignore error on refresh of materialized views
pum baseline -d delta -p qgep_prod -t qgep_sys.pum_info -b 1.0.0
pum test-and-upgrade -pp qgep_prod -pt qgep_test -pc qgep_comp -x -f pum_backup.dump -t qgep_sys.pum_info -d delta/ -i constraints views triggers --exclude-schema public -v int SRID 2056   --exclude-field-pattern 'identifier' --exclude-field-pattern 'sige_%' 
rm pum_backup.dump

psql -d qgep_prod -f datamodel/07_views_for_network_tracking.sql -v SRID=2056

# TODO: renname sige to usr_ columns
# schema from s2roche Carto: modifier la target dans le cron job


popd
