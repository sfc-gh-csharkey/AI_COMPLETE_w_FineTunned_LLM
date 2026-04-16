-- Step 1: Launch the fine-tuning job
SELECT SNOWFLAKE.CORTEX.FINETUNE(
    'CREATE',
    'FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.customer_service_classifier',
    'llama3-8b',
    'SELECT prompt, completion FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.FT_TRAINING_DATA',
    'SELECT prompt, completion FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.FT_VALIDATION_DATA'
);
-- Returns a job ID like: ft_900bd0d4-24f0-4231-b458-9344b739a846
-- Finetunning w/ 2600 rows of training data took ~ 9 minutes

-- Step 2: Check job status (replace job ID with the one returned above)
SELECT SNOWFLAKE.CORTEX.FINETUNE(
     'DESCRIBE',
     'ft_900bd0d4-24f0-4231-b458-9344b739a846'
);

-- Step 3: List all fine-tuning jobs
SELECT SNOWFLAKE.CORTEX.FINETUNE('SHOW');

-- Optional cancell fine tune job
-- SELECT SNOWFLAKE.CORTEX.FINETUNE('CANCEL', 'ft_900bd0d4-24f0-4231-b458-9344b739a846');

