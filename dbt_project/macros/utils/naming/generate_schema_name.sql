{#-
  generate_schema_name — nadpisanie domyślnego makra dbt na potrzeby
  dbt Projects on Snowflake.

  Cel:
    - W targecie 'personal' wszystkie modele dewelopera lądują w JEDNYM schemacie
      nazwanym jego loginem Snowflake (PERSONAL_DEVELOPMENT.<login>),
      niezależnie od custom_schema z dbt_project.yml. Piaskownica jest płaska
      — bez podziału na warstwy.
    - W targetach dev/prd zachowujemy domyślny wzorzec dbt:
      <target.schema>_<custom_schema>.

  Reguły:
    target.name == 'personal':
      ZAWSZE -> <login_usera>   (custom_schema IGNOROWANY)
    target.name in (dev, prd):
      brak custom_schema  ->  <target.schema>
      jest custom_schema  ->  <target.schema>_<custom_schema>

  Wymagania (Snowflake nie tworzy schematów automatycznie pod dbt on Snowflake):
    - Baza PERSONAL_DEVELOPMENT musi istnieć, dev musi mieć do niej dostęp.
    - Dla personal: jednorazowo zakładamy `PERSONAL_DEVELOPMENT.<login>` per dev
      (skrypt 02_onboard_dev.sql).
    - Dla dev/prd: schematy <ENV>, <ENV>_<warstwa> przygotowane przez 01_setup.sql.

  Uwaga implementacyjna:
    run_query("SELECT CURRENT_USER()") odpala się dla każdego modelu w fazie
    rozwiązywania nazw — zapytanie kontekstowe, znikomy koszt; uwzględnić
    przy bardzo dużej liczbie modeli (>1000).
-#}
{%- macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name == 'personal' -%}
        {#- Personal: jeden schemat = login usera, custom_schema ignorowany. -#}
        {%- if execute -%}
            {%- set query_result = run_query("SELECT LOWER(CURRENT_USER())") -%}
            {{ query_result.columns[0].values()[0] | trim }}
        {%- else -%}
            unknown_user
        {%- endif -%}
    {%- elif custom_schema_name is none -%}
        {{ target.schema | trim }}
    {%- else -%}
        {{ target.schema | trim }}_{{ custom_schema_name | trim | lower }}
    {%- endif -%}

{%- endmacro -%}
