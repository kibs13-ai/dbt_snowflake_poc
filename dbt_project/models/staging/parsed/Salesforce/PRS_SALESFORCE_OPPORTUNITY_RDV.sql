{#-
  PRS_SALESFORCE_OPPORTUNITY_RDV — parsed layer dla Salesforce Opportunity.

  Zadania:
    - Czyta STG_SALESFORCE_OPPORTUNITY
    - Renamuje *_ID źródłowe na *_BK (business keys):
        ID            -> OPPORTUNITY_BK
        ACCOUNT_ID    -> ADVERTISER_BK
        CAMPAIGN_ID   -> PROJECT_BK
        OWNER_ID      -> EMPLOYEE_BK
        AGENCY_C      -> AGENCY_BK
        BRAND_C       -> BRAND_BK
    - Kalkuluje hash keys (MD5_BINARY) dla wszystkich Hub-ów referowanych
      z opportunity (H_OPPORTUNITY, H_QUOTE, H_EMPLOYEE, H_PROJECT, H_BRAND,
      H_ADVERTISER, H_AGENCY) — używane w L i S.
    - Kalkuluje L_OPPORTUNITY_PARTIES_HK = hash(OPP_BK, BRAND_BK, ADV_BK, AGY_BK)
    - Kalkuluje S_OPPORTUNITY_SALESFORCE_HDIFF = hash atrybutów opisowych

  Materialization: view (lekki, świeży snapshot, taniej niż table).

  Konwencja hashowania:
    HK:    MD5_BINARY(UPPER(TRIM(COALESCE(BK, '~~NULL~~'))))
    Link:  MD5_BINARY(zł UPPER(TRIM(COALESCE(...))) '||' złączone)
    HDIFF: MD5_BINARY(zł COALESCE(CAST(... AS VARCHAR), '~~NULL~~') '||' złączone)

    Marker '~~NULL~~' dla COALESCE, żeby NULL nie kolidował z prawdziwą wartością.
-#}
{{ config(materialized='view') }}

WITH stg AS (
    SELECT * FROM {{ ref('STG_SALESFORCE_OPPORTUNITY') }}
)

SELECT
    -- ===== TECH columns (propagacja) =====
    stg.TECH_LOAD_TS,
    stg.TECH_SOURCE_SYSTEM,
    stg.TECH_DBT_MODEL_NAME,
    stg.TECH_DBT_ENV_NAME,
    stg.TECH_DBT_INVOCATION_ID,
    stg.TECH_DBT_JOB_RUN_ID,
    stg.TECH_DBT_JOB_ID,
    stg.TECH_DBT_JOB_TRIGGER,

    -- ===== Business keys (rename + cast) =====
    CAST(stg.ID AS VARCHAR)                  AS OPPORTUNITY_BK,
    CAST(stg.IS_DELETED AS VARCHAR)          AS IS_DELETED,
    CAST(stg.ACCOUNT_ID AS VARCHAR)          AS ADVERTISER_BK,
    CAST(stg.RECORD_TYPE_ID AS VARCHAR)      AS RECORD_TYPE_ID,
    CAST(stg.NAME AS VARCHAR)                AS NAME,
    CAST(stg.STAGE_NAME AS VARCHAR)          AS STAGE_NAME,
    CAST(stg.AMOUNT AS NUMBER(18,2))         AS AMOUNT,
    CAST(stg.IS_CLOSED AS VARCHAR)           AS IS_CLOSED,
    CAST(stg.IS_WON AS VARCHAR)              AS IS_WON,
    CAST(stg.CAMPAIGN_ID AS VARCHAR)         AS PROJECT_BK,
    CAST(stg.OWNER_ID AS VARCHAR)            AS EMPLOYEE_BK,
    CAST(stg.SYNCED_QUOTE_ID AS VARCHAR)     AS SYNCED_QUOTE_ID,
    CAST(stg.AGENCY_C AS VARCHAR)            AS AGENCY_BK,
    CAST(stg.BRAND_C AS VARCHAR)             AS BRAND_BK,
    CAST(stg.OPPORTUNITY_NUMBER_C AS VARCHAR) AS OPPORTUNITY_NUMBER_C,
    CAST(stg.CONJOINED_ORDER_C AS VARCHAR)   AS CONJOINED_ORDER_C,

    -- ===== Hash keys (Hubs) =====
    MD5_BINARY(UPPER(TRIM(COALESCE(stg.ID, '~~NULL~~'))))               AS H_OPPORTUNITY_HK,
    MD5_BINARY(UPPER(TRIM(COALESCE(stg.SYNCED_QUOTE_ID, '~~NULL~~'))))  AS H_QUOTE_HK,
    MD5_BINARY(UPPER(TRIM(COALESCE(stg.OWNER_ID, '~~NULL~~'))))         AS H_EMPLOYEE_HK,
    MD5_BINARY(UPPER(TRIM(COALESCE(stg.CAMPAIGN_ID, '~~NULL~~'))))      AS H_PROJECT_HK,
    MD5_BINARY(UPPER(TRIM(COALESCE(stg.BRAND_C, '~~NULL~~'))))          AS H_BRAND_HK,
    MD5_BINARY(UPPER(TRIM(COALESCE(stg.ACCOUNT_ID, '~~NULL~~'))))       AS H_ADVERTISER_HK,
    MD5_BINARY(UPPER(TRIM(COALESCE(stg.AGENCY_C, '~~NULL~~'))))         AS H_AGENCY_HK,

    -- ===== Link key — L_OPPORTUNITY_PARTIES (opp + brand + advertiser + agency) =====
    MD5_BINARY(
        UPPER(TRIM(COALESCE(stg.ID, '~~NULL~~')))         || '||' ||
        UPPER(TRIM(COALESCE(stg.BRAND_C, '~~NULL~~')))    || '||' ||
        UPPER(TRIM(COALESCE(stg.ACCOUNT_ID, '~~NULL~~'))) || '||' ||
        UPPER(TRIM(COALESCE(stg.AGENCY_C, '~~NULL~~')))
    )                                                                    AS L_OPPORTUNITY_PARTIES_HK,

    -- ===== HDIFF — Satellite S_OPPORTUNITY_SALESFORCE (atrybuty opisowe) =====
    MD5_BINARY(
        COALESCE(CAST(stg.NAME AS VARCHAR), '~~NULL~~')                  || '||' ||
        COALESCE(CAST(stg.OPPORTUNITY_NUMBER_C AS VARCHAR), '~~NULL~~')  || '||' ||
        COALESCE(CAST(stg.SYNCED_QUOTE_ID AS VARCHAR), '~~NULL~~')       || '||' ||
        COALESCE(CAST(stg.CONJOINED_ORDER_C AS VARCHAR), '~~NULL~~')
    )                                                                    AS S_OPPORTUNITY_SALESFORCE_HDIFF
FROM stg
