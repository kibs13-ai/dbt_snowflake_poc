{#-
  generate_database_name — nadpisanie domyślnego makra dbt.

  Cel:
    - personal_*: ignoruje custom_database z dbt_project.yml; wszystkie modele
                  lądują w bazie z profiles.yml (PERSONAL_DEVELOPMENT).
    - dev/prd:    do custom_database (np. DB_TVN_AD_SALES_LOAD_STAGE) dokleja
                  sufix środowiska na podstawie target.name
                  -> DB_TVN_AD_SALES_LOAD_STAGE_DEV / _PRD

  Wzorzec custom_database w dbt_project.yml:
    +database: DB_TVN_AD_SALES_LOAD_STAGE   (bez sufiksu env — domykamy tu)
-#}
{%- macro generate_database_name(custom_database_name, node) -%}
    {%- if target.name.startswith('personal') -%}
        {{ target.database | trim }}
    {%- elif custom_database_name -%}
        {{ custom_database_name | trim }}_{{ target.name | upper | trim }}
    {%- else -%}
        {{ target.database | trim }}
    {%- endif -%}
{%- endmacro -%}
