{#-
  generate_schema_name — nadpisanie domyślnego makra dbt na potrzeby
  dbt Projects on Snowflake.

  Cel:
    - W targecie 'personal' każdy dev pracuje w bazie PERSONAL_DEVELOPMENT,
      w schemacie nazwanym jego loginem Snowflake — bez ręcznej edycji
      profiles.yml (jeden plik dla całego zespołu).
    - W targetach dev/test/prd zachowujemy domyślny wzorzec dbt:
      <target.schema>_<custom_schema>.

  Reguły:
    target.name == 'personal':
      brak custom_schema  ->  <login_usera>
      jest custom_schema  ->  <login_usera>_<custom_schema>
    target.name in (dev, test, prd):
      brak custom_schema  ->  <target.schema>
      jest custom_schema  ->  <target.schema>_<custom_schema>

  Wymagania (Snowflake nie tworzy schematów automatycznie pod dbt on Snowflake):
    - Baza PERSONAL_DEVELOPMENT musi istnieć, dev musi mieć do niej dostęp.
    - Schematy używane przez modele muszą istnieć PRZED `EXECUTE DBT PROJECT`.
      Dla personal: jednorazowo per dev (np. `CREATE SCHEMA PERSONAL_DEVELOPMENT.alicja`
      oraz schematy <login>_staging, <login>_rdv jeśli używamy custom_schema).
      Dla dev/test/prd: Liquibase tworzy je przed deployem.

  Uwaga implementacyjna:
    run_query("SELECT CURRENT_USER()") odpala się dla każdego modelu w fazie
    rozwiązywania nazw — zapytanie kontekstowe, znikomy koszt; uwzględnić
    przy bardzo dużej liczbie modeli (>1000).
-#}
{%- macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name == 'personal' -%}
        {%- if execute -%}
            {%- set query_result = run_query("SELECT LOWER(CURRENT_USER())") -%}
            {%- set base_schema = query_result.columns[0].values()[0] -%}
        {%- else -%}
            {%- set base_schema = 'unknown_user' -%}
        {%- endif -%}
    {%- else -%}
        {%- set base_schema = target.schema -%}
    {%- endif -%}

    {%- if custom_schema_name is none -%}
        {{ base_schema | trim }}
    {%- else -%}
        {{ base_schema | trim }}_{{ custom_schema_name | trim | lower }}
    {%- endif -%}

{%- endmacro -%}
