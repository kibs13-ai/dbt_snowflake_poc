{#-
  log_target_info — diagnostyczne makro do sprawdzenia, co adapter dbt-snowflake
  wystawia w target.* w managed runtime dbt on Snowflake.

  Pytanie kluczowe: czy target.user zwraca rzeczywisty login Snowflake (wtedy
  możemy go użyć w generate_schema_name automatycznie), czy zwraca dosłownie
  'not needed' z profiles.yml.

  Wywołanie:
    dbt run-operation log_target_info --target personal

  Po sprawdzeniu — usunąć ten plik (nie jest potrzebny w runtime).
-#}
{% macro log_target_info() %}
    {% do log("=== target.* w bieżącym kontekście ===", info=True) %}
    {% do log("target.name:      " ~ target.name,      info=True) %}
    {% do log("target.type:      " ~ target.type,      info=True) %}
    {% do log("target.user:      " ~ target.user,      info=True) %}
    {% do log("target.account:   " ~ target.account,   info=True) %}
    {% do log("target.role:      " ~ target.role,      info=True) %}
    {% do log("target.database:  " ~ target.database,  info=True) %}
    {% do log("target.schema:    " ~ target.schema,    info=True) %}
    {% do log("target.warehouse: " ~ target.warehouse, info=True) %}
    {% do log("target.threads:   " ~ target.threads,   info=True) %}
{% endmacro %}
