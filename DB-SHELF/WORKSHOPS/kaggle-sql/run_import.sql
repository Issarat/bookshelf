\set ON_ERROR_STOP on
-- Run 00_setup.sql once first. All includes are relative to this script.
\ir 01_load.sql
\ir 01_cleanse.sql
\ir 02_validate.sql
\ir 03_migrate.sql
\ir 04_verify.sql
