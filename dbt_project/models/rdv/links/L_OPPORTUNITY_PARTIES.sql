{#-
  L_OPPORTUNITY_PARTIES — Link Data Vault: relacja Opportunity <-> Brand <-> Advertiser <-> Agency.

  Wzorzec ręczny CTAS (zamiast datavault4dbt).

  Reguły:
    - Jeden wiersz per L_OPPORTUNITY_PARTIES_HK (unique kombinacja BK)
    - Najstarsze LDTS wygrywa (first-seen)
    - Driving key (DK) = H_OPPORTUNITY_HK (per Data Vault convention)
    - Wiersze z OPPORTUNITY_BK = NULL odrzucone
    - NULL w BRAND/AGENCY/ADVERTISER są dozwolone — odpowiada im hash('~~NULL~~')
      i tworzy konkretny link record. Realistyczne dla opp bez agency/brand.

  Materialization: table.
-#}
{{ config(materialized='table') }}

WITH source AS (
    SELECT
        L_OPPORTUNITY_PARTIES_HK,
        H_OPPORTUNITY_HK,
        H_BRAND_HK,
        H_ADVERTISER_HK,
        H_AGENCY_HK,
        TECH_LOAD_TS,
        TECH_SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY L_OPPORTUNITY_PARTIES_HK
            ORDER BY TECH_LOAD_TS ASC
        ) AS rn
    FROM {{ ref('PRS_SALESFORCE_OPPORTUNITY_RDV') }}
    WHERE OPPORTUNITY_BK IS NOT NULL
)

SELECT
    L_OPPORTUNITY_PARTIES_HK,
    TECH_LOAD_TS        AS LDTS,
    TECH_SOURCE_SYSTEM  AS RSRC,
    H_OPPORTUNITY_HK    AS H_OPPORTUNITY_HK_DK,    -- DK = driving key
    H_BRAND_HK,
    H_ADVERTISER_HK,
    H_AGENCY_HK
FROM source
WHERE rn = 1
