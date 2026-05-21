{#-
  STG_SALESFORCE_OPPORTUNITY — staging dla Salesforce Opportunity.

  Zadania:
    - Czyta source SRC_SALESFORCE_OPPORTUNITY (z baz LOAD_STAGE wg targetu)
    - Dodaje kolumny TECH_DBT_* z kontekstu dbt (model, env, invocation)
    - Propaguje TECH_LOAD_TS i TECH_SOURCE_SYSTEM ze SRC
    - Bez transformacji biznesowych — wszystkie kolumny 1:1 ze SRC

  Materialization: table transient (zgodnie z konwencją STG = transient).
-#}
{{
  config(
    materialized='table',
    transient=true
  )
}}

SELECT
    -- ===== TECH columns z kontekstu dbt =====
    '{{ this.name }}'::VARCHAR                          AS TECH_DBT_MODEL_NAME,
    '{{ target.name }}'::VARCHAR                        AS TECH_DBT_ENV_NAME,
    '{{ invocation_id }}'::VARCHAR                      AS TECH_DBT_INVOCATION_ID,
    NULL::VARCHAR                                       AS TECH_DBT_JOB_RUN_ID,
    NULL::VARCHAR                                       AS TECH_DBT_JOB_ID,
    NULL::VARCHAR                                       AS TECH_DBT_JOB_TRIGGER,

    -- ===== TECH columns propagowane ze SRC =====
    src.TECH_LOAD_TS,
    src.TECH_SOURCE_SYSTEM,

    -- ===== Business columns 1:1 ze SRC =====
    src.ID,
    src.IS_DELETED,
    src.ACCOUNT_ID,
    src.RECORD_TYPE_ID,
    src.NAME,
    src.DESCRIPTION,
    src.STAGE_NAME,
    src.AMOUNT,
    src.PROBABILITY,
    src.CLOSE_DATE,
    src.TYPE,
    src.IS_CLOSED,
    src.IS_WON,
    src.FORECAST_CATEGORY,
    src.FORECAST_CATEGORY_NAME,
    src.CAMPAIGN_ID,
    src.HAS_OPPORTUNITY_LINE_ITEM,
    src.PRICEBOOK2_ID,
    src.OWNER_ID,
    src.CREATED_DATE,
    src.CREATED_BY_ID,
    src.LAST_MODIFIED_DATE,
    src.LAST_MODIFIED_BY_ID,
    src.SYSTEM_MODSTAMP,
    src.SYNCED_QUOTE_ID,
    src.VLOCITY_CMT_BUDGET_AMOUNT_C,
    src.VLOCITY_CMT_PRICE_LIST_ID_C,
    src.AGENCY_C,
    src.LOSS_REASON_C,
    src.PARTY_RELATIONSHIP_C,
    src.BRAND_C,
    src.OPPORTUNITY_NUMBER_C,
    src.CONJOINED_ORDER_C,
    src.DAY
FROM {{ source('SALESFORCE', 'SRC_SALESFORCE_OPPORTUNITY') }} AS src
