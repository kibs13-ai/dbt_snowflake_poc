{#-
  S_OPPORTUNITY_SALESFORCE — Satellite Data Vault z atrybutami opisowymi opportunity.

  Wzorzec ręczny CTAS (zamiast datavault4dbt).

  Atrybuty:
    - NAME, OPPORTUNITY_NUMBER_C, SYNCED_QUOTE_ID, CONJOINED_ORDER_C

  Reguły:
    - Klucz: (H_OPPORTUNITY_HK, LDTS) — historyzacja zmian atrybutów
    - HDIFF wyliczany w PRS (hash wszystkich atrybutów opisowych)
    - Każda kombinacja (HK, HDIFF) tylko raz — pierwsze pojawienie się
    - Wiersze z OPPORTUNITY_BK = NULL odrzucone

  Materialization: table.

  W realnym setupie incremental: load tylko nowych (HK, HDIFF). Dla PoC table.
-#}
{{ config(materialized='table') }}

WITH source AS (
    SELECT
        H_OPPORTUNITY_HK,
        S_OPPORTUNITY_SALESFORCE_HDIFF,
        TECH_LOAD_TS,
        TECH_SOURCE_SYSTEM,
        NAME,
        OPPORTUNITY_NUMBER_C,
        SYNCED_QUOTE_ID,
        CONJOINED_ORDER_C,
        ROW_NUMBER() OVER (
            PARTITION BY H_OPPORTUNITY_HK, S_OPPORTUNITY_SALESFORCE_HDIFF
            ORDER BY TECH_LOAD_TS ASC
        ) AS rn
    FROM {{ ref('PRS_SALESFORCE_OPPORTUNITY_RDV') }}
    WHERE OPPORTUNITY_BK IS NOT NULL
)

SELECT
    H_OPPORTUNITY_HK,
    S_OPPORTUNITY_SALESFORCE_HDIFF,
    TECH_LOAD_TS        AS LDTS,
    TECH_SOURCE_SYSTEM  AS RSRC,
    NAME,
    OPPORTUNITY_NUMBER_C,
    SYNCED_QUOTE_ID,
    CONJOINED_ORDER_C
FROM source
WHERE rn = 1
