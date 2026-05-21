{#-
  H_OPPORTUNITY — Hub Data Vault dla Salesforce Opportunity.

  Wzorzec ręczny CTAS (zamiast datavault4dbt).

  Reguły:
    - Jeden wiersz per H_OPPORTUNITY_HK (unique business key)
    - Najstarsze LDTS wygrywa (first-seen)
    - Wiersze z OPPORTUNITY_BK = NULL odrzucone
    - RSRC = TECH_SOURCE_SYSTEM (np. 'SALESFORCE')

  Materialization: table.
-#}
{{ config(materialized='table') }}

WITH source AS (
    SELECT
        OPPORTUNITY_BK,
        H_OPPORTUNITY_HK,
        TECH_LOAD_TS,
        TECH_SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY H_OPPORTUNITY_HK
            ORDER BY TECH_LOAD_TS ASC
        ) AS rn
    FROM {{ ref('PRS_SALESFORCE_OPPORTUNITY_RDV') }}
    WHERE OPPORTUNITY_BK IS NOT NULL
)

SELECT
    OPPORTUNITY_BK,
    H_OPPORTUNITY_HK,
    TECH_LOAD_TS        AS LDTS,
    TECH_SOURCE_SYSTEM  AS RSRC
FROM source
WHERE rn = 1
