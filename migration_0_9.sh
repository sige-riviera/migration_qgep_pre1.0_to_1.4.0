#!/usr/bin/env bash

set -e

export IPSOURCE=xxx.xx.xxx.xxx
export PGPASSWORD='pgpassword'
export PGUSER='pguser'
export DBDEST=qgep_0_9
export IPDEST=xxx.xx.xxx.xxx

pg_dump -F p -Z 9 -h $IPSOURCE -n qgep qgep_prod > dump_0_9.zip

dropdb -U sige -h $IPDEST $DBDEST || true
createdb -U sige -O sige -h $IPDEST $DBDEST
psql -d $DBDEST -h $IPDEST -c "CREATE EXTENSION hstore;"
psql -d $DBDEST -h $IPDEST -c "CREATE EXTENSION postgis;"
zcat dump_0_9.zip | grep -vw "idle_in_transaction_session_timeout" | grep -vw "REFRESH MATERIALIZED VIEW vw_network_segment;" | grep -vw "REFRESH MATERIALIZED VIEW vw_network_node;"  | psql -v ON_ERROR_STOP=1 -h $IPDEST -U sige -d $DBDEST

rm dump_0_9.zip
