#!/usr/bin/env bash

set -e

export PGPASSWORD='pgpassword'
export PGUSER='pguser'
export PGHOST='xxx.xx.xxx.xxx'

psql -d devtest -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'qgep_0_9';"
psql -d devtest -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'qgep_1_0';"



dropdb qgep_1_0 || true 
createdb -T qgep_0_9 qgep_1_0 

psql -d qgep_1_0 -c "drop schema if exists qgep_od CASCADE"
psql -d qgep_1_0 -c "drop schema if exists qgep_vl CASCADE"
psql -d qgep_1_0 -c "drop schema if exists qgep_sys CASCADE"

#pg_restore --dbname "qgep_1_0" qgep_v1.0.0_structure_only.backup
#pg_restore --dbname "qgep_1_0" qgep_v1.0.0_value_list_data_only.backup



cat qgep_v1.0.0_structure_only.sql | grep -vw "idle_in_transaction_session_timeout" | psql -d qgep_1_0 -v ON_ERROR_STOP=1
cat qgep_v1.0.0_value_list_data_only.sql | grep -vw "idle_in_transaction_session_timeout" | psql -d qgep_1_0 -v ON_ERROR_STOP=1

psql -d qgep_1_0 -v ON_ERROR_STOP=1 -f drop_views.sql

psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "DROP VIEW qgep_od.vw_maintenance_examination"
psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "DROP VIEW qgep_od.vw_qgep_reach"

psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "DROP MATERIALIZED VIEW qgep_od.vw_network_node"

psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "ALTER TABLE qgep_od.maintenance_event ALTER COLUMN base_data TYPE varchar(200)"
psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "ALTER TABLE qgep_od.structure_part ALTER COLUMN identifier TYPE varchar(200)"
psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "ALTER TABLE qgep_od.wastewater_networkelement ALTER COLUMN identifier TYPE varchar(200)"
psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "ALTER TABLE qgep_od.wastewater_structure ALTER COLUMN identifier TYPE varchar(200)"


# Add SIGE colums
psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "ALTER TABLE qgep_od.reach ADD COLUMN sige_collecting_pipe_id integer"
psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "ALTER TABLE qgep_od.reach ADD COLUMN sige_batch_cleaning_id integer"
psql -d qgep_1_0 -v ON_ERROR_STOP=1 -c "ALTER TABLE qgep_od.reach ADD COLUMN sige_batch_inspection_id integer"

# Copy tables
echo "*** copy tables"
export PGOPTIONS='--client-min-messages=notice'
psql -d qgep_1_0 -f migrate_dispatch_copy_data.sql 2> migration.log

cat migration.log | sed 's/\bERROR:/ZERROR:/' | sed -r 's/^.*(INFO|NOTICE|WARNING|ERROR)/\1/' | sort -r | sed 's/\bZERROR:/ERROR:/' > migration2.log
CERR=$(cat migration2.log | egrep 'ERROR:' | wc -l)
CWARN=$(cat migration2.log | egrep 'WARNING:' | wc -l)
CNOT=$(cat migration2.log | egrep 'NOTICE:' | wc -l)
cat migration2.log | sort
if [[ "$CERR" -ne "0" ]]; then
  echo "!!! Migration failed with ${CERR} errors and ${CWARN} warnings."
else
  echo "**************"
  echo "**************"
  echo " Migration done with"
  echo "  ${CWARN} warnings"
  echo "  ${CNOT} notices (columns skip or rename)."
  echo "**************"
  cat migration2.log | egrep 'WARNING:' || /bin/true
  echo "**************"
  cat migration2.log | egrep '[^0]\d* elements' | sed 's/INFO:\s*/ /'
  echo "**************"
  echo "**************"
fi
rm migration.log
rm migration2.log

# remove schema with 0.9 model
psql -d qgep_1_0 -c "DROP SCHEMA qgep CASCADE"


# data fixes, déplacement des geom nulles dans le lac
psql -d qgep_1_0 -c "UPDATE qgep_od.wastewater_node SET situation_geometry = ST_SetSRID(ST_MakePoint(2558335.0, 1142539.0), 2056) WHERE situation_geometry IS NULL"
psql -d qgep_1_0 -c "UPDATE qgep_od.cover SET situation_geometry = ST_SetSRID(ST_MakePoint(2558335.0, 1142539.0), 2056) WHERE situation_geometry IS NULL"
