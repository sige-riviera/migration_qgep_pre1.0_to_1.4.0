#!/usr/bin/env bash

# A LANCER APRES LA MIGRATION

set -e

export IPSOURCE=xxx.xx.xxx.xxx
export PGPASSWORD='pgpassword$'
export PGUSER='pguser'
export DBDEST=qgep_prod
export IPDEST=xxx.xx.xxx.xxx

pg_dump -F p -Z 9 -h $IPSOURCE -n qgep_sige qgep_prod > dump_qgep_sige.zip

psql -d qgep_prod -c "DROP SCHEMA qgep_sige CASCADE"

zcat dump_qgep_sige.zip | grep -vw "idle_in_transaction_session_timeout" | sed -r 's/qgep\.(od|vl|sys)_/qgep_\1./g' | sed -r 's/qgep\.(re|vw)_/qgep_od.\1_/g' | sed -r 's/od_(reach)/\1/g' | psql -v ON_ERROR_STOP=1 -h $IPDEST -U sige -d $DBDEST

rm dump_qgep_sige.zip
