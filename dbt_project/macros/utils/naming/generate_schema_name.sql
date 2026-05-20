{#-
  generate_schema_name — nadpisanie domyślnego makra dbt na potrzeby
  dbt Projects on Snowflake.

  Cel:
    - W targecie 'personal' wszystkie modele dewelopera lądują w JEDNYM schemacie
      nazwanym jego loginem Snowflake (PERSONAL_DEVELOPMENT.<login>),
      niezależnie od custom_schema z dbt_project.yml.
    - W targetach dev/prd zachowujemy domyślny wzorzec dbt:
      <target.schema>_<custom_schema>.

  Reguły:
    target.name == 'personal':
      schemat = var('dev_user') | lower    (custom_schema IGNOROWANY)
      fallback (brak vara): target.schema  (PUBLIC z profiles.yml — sygnał błędu)
    target.name in (dev, prd):
      brak custom_schema  ->  <target.schema>
      jest custom_schema  ->  <target.schema>_<custom_schema>

  Dlaczego var, a nie run_query("CURRENT_USER()"):
    dbt 1.9 parsuje schematy STATYCZNIE w fazie parse (execute=False),
    a dbt Projects on Snowflake nie wspiera env_var(). Wynik:
    run_query nie zwraca wartości w parse, fallback dawał 'unknown_user'.
    Vars to jedyna w pełni działająca droga w tym setupie.

  Sposób użycia w personal:
    Każdy dev podaje swój login w args= dbt-a:
      dbt run --vars '{dev_user: jakub_wojciechowski}' --select <model>

  Wymagania (Snowflake nie tworzy schematów automatycznie pod dbt on Snowflake):
    - Schemat PERSONAL_DEVELOPMENT.<login> musi istnieć przed runem
      (skrypt 02_onboard_dev.sql).
    - Dla dev/prd: schematy <ENV>, <ENV>_<warstwa> przygotowane w 01_setup.sql.
-#}
{%- macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name == 'personal' -%}
        {{ var('dev_user', target.schema) | lower | trim }}
    {%- elif custom_schema_name is none -%}
        {{ target.schema | trim }}
    {%- else -%}
        {{ target.schema | trim }}_{{ custom_schema_name | trim | lower }}
    {%- endif -%}

{%- endmacro -%}
