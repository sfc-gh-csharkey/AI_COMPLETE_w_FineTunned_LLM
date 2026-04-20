-- 04_Cost_Summary.sql

-- Cost summary and optimization tips for the FINETUNING_AI_COMPLETE demo
-- This version uses:
--   - Actual token + credit data from ACCOUNT_USAGE
--   - An effective AI $/credit based on current Service Consumption Table
--     (On-Demand AI Credits ≈ $2.00 per credit for Tier 1). Adjust below
--     if your contract or reseller pricing differs.

------------------------------------------------------------------------
-- 1) PARAMETERS: set your effective $/credit for AI usage
------------------------------------------------------------------------
-- Adjust this to your actual contract rate if needed
SET AI_CREDIT_PRICE_PER_CREDIT = 2.0;  -- USD per credit (update if different)
SET AI_USAGE_LOOKBACK_DAYS = 1;        -- Number of days to look back for usage data

------------------------------------------------------------------------
-- 2) COST SUMMARY BY FUNCTION / MODEL FOR THIS DEMO
------------------------------------------------------------------------
-- Filters:
--   - Database/schema used by the demo
--   - Only the three relevant functions
--   - Lookback window controlled by AI_USAGE_LOOKBACK_DAYS parameter
WITH raw_usage AS (
  SELECT
      c.FUNCTION_NAME,
      c.MODEL_NAME,
      SUM(c.TOKENS)        AS TOTAL_TOKENS,
      SUM(c.TOKEN_CREDITS) AS TOTAL_AI_CREDITS
  FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AISQL_USAGE_HISTORY c
  JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
    ON c.QUERY_ID = q.QUERY_ID
  WHERE q.DATABASE_NAME = 'FINETUNING_AI_COMPLETE'
    AND q.SCHEMA_NAME   = 'CALL_TRANSCRIPTS'
    AND c.FUNCTION_NAME IN ('AI_CLASSIFY', 'COMPLETE', 'FINETUNE')
    AND c.USAGE_TIME >= DATEADD(DAY, -$AI_USAGE_LOOKBACK_DAYS, CURRENT_TIMESTAMP())
  GROUP BY c.FUNCTION_NAME, c.MODEL_NAME
),
row_counts AS (
  SELECT COUNT(*) AS NUM_ROWS
  FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.RAW_TRANSCRIPTS
)
SELECT
    u.FUNCTION_NAME,
    u.MODEL_NAME,
    r.NUM_ROWS,
    u.TOTAL_TOKENS,
    ROUND(u.TOTAL_TOKENS / NULLIF(r.NUM_ROWS, 0), 2) AS TOKENS_PER_ROW_ACTUAL,
    u.TOTAL_AI_CREDITS,
    ROUND(u.TOTAL_AI_CREDITS * $AI_CREDIT_PRICE_PER_CREDIT, 4) AS EST_COST_USD,
    ROUND(u.TOTAL_AI_CREDITS / NULLIF(r.NUM_ROWS, 0), 6) AS CREDITS_PER_ROW,
    ROUND((u.TOTAL_AI_CREDITS / NULLIF(r.NUM_ROWS, 0)) * $AI_CREDIT_PRICE_PER_CREDIT, 6) AS USD_PER_ROW
FROM raw_usage u
CROSS JOIN row_counts r
ORDER BY u.FUNCTION_NAME, u.MODEL_NAME;

------------------------------------------------------------------------
-- 3) OPTIONAL: MOST RECENT QUERIES WITH PER-QUERY COST
------------------------------------------------------------------------
SELECT
    c.USAGE_TIME,
    c.QUERY_ID,
    c.FUNCTION_NAME,
    c.MODEL_NAME,
    c.TOKENS,
    c.TOKEN_CREDITS,
    ROUND(c.TOKEN_CREDITS * $AI_CREDIT_PRICE_PER_CREDIT, 6) AS EST_COST_USD
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AISQL_USAGE_HISTORY c
JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
  ON c.QUERY_ID = q.QUERY_ID
WHERE q.DATABASE_NAME = 'FINETUNING_AI_COMPLETE'
  AND q.SCHEMA_NAME   = 'CALL_TRANSCRIPTS'
  AND c.FUNCTION_NAME IN ('AI_CLASSIFY', 'COMPLETE', 'FINETUNE')
ORDER BY c.USAGE_TIME DESC
LIMIT 20;

------------------------------------------------------------------------
-- 4) COST OPTIMIZATION TIPS (COMMENT-ONLY SECTION)
------------------------------------------------------------------------
-- Tip 1: For AI_CLASSIFY, keep a single call per row with all labels
--        in one array; avoid one call per label (6× cost for 6 labels).
--
-- Tip 2: Minimize classification prompt length, label descriptions,
--        and examples; every token here is charged per row. Use this
--        script’s TOKENS_PER_ROW_ACTUAL to see real impact.
--
-- Tip 3: For the fine-tuned COMPLETE path, keep prompts short and set
--        max_tokens low (just enough to output one category label) to
--        avoid unnecessary output tokens.
--
-- Tip 4: Use AI_CLASSIFY for quick, low-volume baselines; switch to a
--        fine-tuned llama3-8b + COMPLETE once you expect large, repeated
--        workloads so the one-time FINETUNE cost amortizes over many
--        inferences (you’ll see that in TOTAL_AI_CREDITS for FINETUNE
--        vs COMPLETE here).
--
-- Tip 5: Always test on a small sample first, then extrapolate using
--        TOKEN_CREDITS × $/credit from this script before committing
--        to large production runs.