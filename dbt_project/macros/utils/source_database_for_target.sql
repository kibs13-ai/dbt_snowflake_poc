{#-
  source_database_for_target — wybór bazy źródłowej (SCH_SRC) w zależności od targetu.

  Zastępuje `env_var('DBT_ENV_NAME')` (nieobsługiwane w dbt on Snowflake).

  Reguły:
    target=personal_*  ->  DB_TVN_AD_SALES_LOAD_STAGE_PRD
                          (developer w sandboxie czyta source z produkcji —
                           decyzja architektoniczna PoC)
    target=dev         ->  DB_TVN_AD_SALES_LOAD_STAGE_DEV
    target=prd         ->  DB_TVN_AD_SALES_LOAD_STAGE_PRD

  Używane w models/staging/src/Salesforce/_src_salesforce.yml.
-#}
{%- macro source_database_for_target() -%}
    {%- if target.name.startswith('personal') or target.name == 'prd' -%}
        DB_TVN_AD_SALES_LOAD_STAGE_PRD
    {%- elif target.name == 'dev' -%}
        DB_TVN_AD_SALES_LOAD_STAGE_DEV
    {%- else -%}
        {{ exceptions.raise_compiler_error(
            "source_database_for_target: nieznany target '" ~ target.name ~
            "'. Dozwolone: personal_*, dev, prd."
        ) }}
    {%- endif -%}
{%- endmacro -%}
