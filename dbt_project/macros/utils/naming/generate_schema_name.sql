{#-
  generate_schema_name — nadpisanie domyślnego makra dbt.

  Cel:
    - personal_*: ignoruje custom_schema z dbt_project.yml; wszystkie modele
                  lądują w jednym schemacie = target.schema (login dev'a).
    - dev/prd:    używa custom_schema z dbt_project.yml (SCH_STAGE, SCH_PARSED,
                  SCH_RDV) jeśli ustawione; fallback target.schema.

  Wzorzec użycia w dbt_project.yml:
    staging:
      stage:
        +schema: SCH_STAGE          # dla dev/prd; personal ignoruje
      parsed:
        +schema: SCH_PARSED
    rdv:
      +schema: SCH_RDV
-#}
{%- macro generate_schema_name(custom_schema_name, node) -%}
    {%- if target.name.startswith('personal') -%}
        {{ target.schema | lower | trim }}
    {%- elif custom_schema_name -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema | trim }}
    {%- endif -%}
{%- endmacro -%}
