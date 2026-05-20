{#-
  generate_schema_name — nadpisanie domyślnego makra dbt na potrzeby
  dbt Projects on Snowflake.

  Cel:
    - W targetach personal_<login> wszystkie modele dewelopera lądują w JEDNYM
      schemacie nazwanym jego loginem (PERSONAL_DEVELOPMENT.<login>),
      niezależnie od custom_schema z dbt_project.yml. Schemat pochodzi
      bezpośrednio z target.schema — hardcoded w profiles.yml per dev.
    - W targetach dev/prd zachowujemy domyślny wzorzec dbt:
      <target.schema>_<custom_schema>.

  Reguły:
    target.name.startswith('personal'):
      schemat = target.schema (z profiles.yml — login dewelopera)
      custom_schema IGNOROWANY (piaskownica płaska, bez warstw)
    target.name in (dev, prd):
      brak custom_schema  ->  <target.schema>
      jest custom_schema  ->  <target.schema>_<custom_schema>

  Dlaczego per-dev targety zamiast var('dev_user') albo CURRENT_USER():
    - dbt 1.9 parsuje schematy STATYCZNIE (execute=False) — run_query nie działa
    - dbt on Snowflake nie wspiera env_var()
    - target.user w managed runtime zwraca dosłownie 'not needed' z profiles.yml
    Per-dev targety to jedyne pragmatyczne rozwiązanie skalujące się ponad 1 dev.

  Sposób użycia w personal:
    Każdy dev w Workspace ustawia default args: `--target personal_<myname>`.
    Po jednorazowym setupie nie trzeba podawać --target ani --vars.
    Workspace zapamiętuje setting per-user.

  Onboarding nowego dev:
    1. Dopisać 7 linijek `personal_<login>` w profiles.yml (PR)
    2. Uruchomić snowflake/02_onboard_dev.sql (zakłada schemat w PERSONAL_DEVELOPMENT)
    3. Ustawić default --target w Workspace
-#}
{%- macro generate_schema_name(custom_schema_name, node) -%}

    {%- if target.name.startswith('personal') -%}
        {{ target.schema | lower | trim }}
    {%- elif custom_schema_name is none -%}
        {{ target.schema | trim }}
    {%- else -%}
        {{ target.schema | trim }}_{{ custom_schema_name | trim | lower }}
    {%- endif -%}

{%- endmacro -%}
