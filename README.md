# AI_COMPLETE w/ a Fine-Tuned LLM

<img width="85" alt="map-user" src="https://img.shields.io/badge/views-000-green"> <img width="125" alt="map-user" src="https://img.shields.io/badge/unique visits-000-green">

Example of fine-tuning llama3-8b for classification and invoking the fine-tuned model via. AI_COMPLETE. This example compares two approaches to classifying customer service call transcripts into one of six categories: Billing, Technical Support, Account Management, Product Inquiry, Complaint, and Cancellation.

The first approach uses the built-in ```AI_CLASSIFY``` function. The second approach fine-tunes llama3-8b on labeled training data and then runs inference via. ```AI_COMPLETE``` using the fine-tuned model. Both approaches include accuracy evaluation and misclassification analysis so you can compare results.

## How to deploy / use the code sample(s)

This repository uses synthetic call transcript data generated inline via. the setup script. No external data dependencies are required. Run the SQL files in order using a Snowflake worksheet or your SQL tool of choice.

You will need a virtual warehouse to run the SQL scripts. These scripts will not create one for you.

1. Setup

   Run [00_Setup.sql](https://github.com/sfc-gh-csharkey/AI_COMPLETE_w_FineTunned_LLM/blob/main/00_Setup.sql) to create the ```FINETUNING_AI_COMPLETE``` database, ```CALL_TRANSCRIPTS``` schema, and the ```RAW_TRANSCRIPTS``` table populated with ~3,000 synthetic call transcripts across the six categories. This script also creates the ```FT_TRAINING_DATA``` and ```FT_VALIDATION_DATA``` tables formatted for fine-tuning (prompt/completion pairs with an 80/20 split).

2. Baseline with AI_CLASSIFY

   Run [01_AI_CLASSIFY.sql](https://github.com/sfc-gh-csharkey/AI_COMPLETE_w_FineTunned_LLM/blob/main/01_AI_CLASSIFY.sql) to classify all 3,000 transcripts using ```SNOWFLAKE.CORTEX.AI_CLASSIFY```. This establishes a baseline accuracy to compare against the fine-tuned model. The script evaluates overall accuracy, per-category accuracy, and surfaces misclassifications.

3. Fine-Tune llama3-8b

   Run [02_Fine-tune_llama3-8b.sql](https://github.com/sfc-gh-csharkey/AI_COMPLETE_w_FineTunned_LLM/blob/main/02_Fine-tune_llama3-8b.sql) to launch a fine-tuning job via. ```SNOWFLAKE.CORTEX.FINETUNE```. The fine-tuning uses the training and validation data created in step 1 and produces a custom model registered as ```FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.CUSTOMER_SERVICE_CLASSIFIER```. Fine-tuning with ~2,600 rows of training data takes approximately 9 minutes.

4. Inference with the Fine-Tuned Model

   Run [03_Inference.sql](https://github.com/sfc-gh-csharkey/AI_COMPLETE_w_FineTunned_LLM/blob/main/03_Inference.sql) to classify all transcripts using ```SNOWFLAKE.CORTEX.COMPLETE``` with the fine-tuned model. The script evaluates overall accuracy, per-category accuracy, and surfaces misclassifications so you can compare the results against the AI_CLASSIFY baseline from step 2.
