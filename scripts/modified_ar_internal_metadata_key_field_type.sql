DO $$
DECLARE
    sch text;
BEGIN
    FOR sch IN SELECT nspname FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace where nspname != 'pg_toast'
    and n.nspname != 'pg_temp_1' and n.nspname != 'pg_toast_temp_1'
    and n.nspname != 'pg_statistic' and n.nspname != 'pg_catalog'
    and n.nspname != 'information_schema' and n.nspname != 'information_schema'
    and n.nspname != 'shared_extensions' and c.relname = 'ar_internal_metadata'
    and c.relkind = 'r'
    LOOP
        EXECUTE format('SET SEARCH_PATH TO %I ', sch);
        EXECUTE format('ALTER TABLE %1$I.ar_internal_metadata ALTER COLUMN key TYPE varchar', sch);
        EXECUTE format('ALTER TABLE %1$I.ar_internal_metadata ALTER COLUMN key DROP DEFAULT', sch);
    END LOOP;
END; $$;


