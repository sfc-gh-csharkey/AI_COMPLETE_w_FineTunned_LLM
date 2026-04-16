-- Step 1: Create database and schema
CREATE DATABASE IF NOT EXISTS FINETUNING_AI_COMPLETE;
CREATE SCHEMA IF NOT EXISTS FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS;

-- Step 2: Create the raw transcripts table
CREATE OR REPLACE TABLE FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.RAW_TRANSCRIPTS (
    TRANSCRIPT_ID NUMBER AUTOINCREMENT,
    TRANSCRIPT VARCHAR(16777216),
    CATEGORY VARCHAR(50)
);

-- Step 3: Generate ~3,000 sample transcripts across 6 categories
-- Uses template components (greetings, issues, resolutions, closings) combined
-- via GENERATOR + UNIFORM to produce varied but category-appropriate transcripts.
INSERT INTO FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.RAW_TRANSCRIPTS (TRANSCRIPT, CATEGORY)
WITH
-- Customer greetings (10 variations)
greetings AS (
    SELECT column1 AS greeting FROM VALUES
        ('Hi, I''m calling about my account.'),
        ('Hello, I need some help please.'),
        ('Hey there, I have a question.'),
        ('Good morning, I''d like to speak with someone about my service.'),
        ('Hi, I was hoping you could help me with something.'),
        ('Hello, I''ve been trying to get this resolved.'),
        ('Hi, thanks for taking my call.'),
        ('Good afternoon, I need assistance.'),
        ('Hey, I''m a long-time customer and I need help.'),
        ('Hi, I was referred to this department.')
),
-- Agent openings (8 variations)
agent_openings AS (
    SELECT column1 AS agent_opening FROM VALUES
        ('Thank you for calling. I''d be happy to help you today.'),
        ('Welcome, let me pull up your account information.'),
        ('I appreciate you reaching out. How can I assist you?'),
        ('Of course, I''m here to help. Let me take a look.'),
        ('Sure thing, let me see what I can do for you.'),
        ('Absolutely, I''ll do my best to resolve this for you.'),
        ('No problem at all. Let me check on that right away.'),
        ('I understand. Let me review your account details.')
),
-- Category-specific issue descriptions (15 each)
billing_issues AS (
    SELECT column1 AS issue FROM VALUES
        ('I noticed an extra charge of $49.99 on my last statement that I don''t recognize.'),
        ('My bill this month is significantly higher than usual and I don''t understand why.'),
        ('I was supposed to receive a promotional discount but it''s not showing on my bill.'),
        ('I''ve been double-charged for the same service two months in a row.'),
        ('I need to update my payment method on file.'),
        ('Can you explain the breakdown of charges on my latest invoice?'),
        ('I was told my rate would be locked in but my bill went up $20.'),
        ('I have a past-due balance that I believe was already paid.'),
        ('I''d like to set up automatic payments to avoid late fees.'),
        ('There''s a service fee on my bill that wasn''t mentioned when I signed up.'),
        ('I need a copy of my billing history for the last six months.'),
        ('My refund from last month still hasn''t appeared on my statement.'),
        ('I was charged for a premium feature I never activated.'),
        ('Can you help me understand what this recurring $9.99 charge is for?'),
        ('I need to dispute a charge because the service wasn''t delivered as promised.')
),
tech_issues AS (
    SELECT column1 AS issue FROM VALUES
        ('My internet connection keeps dropping every few minutes.'),
        ('I can''t log into my account even though I''m using the correct password.'),
        ('The app crashes every time I try to open the settings page.'),
        ('My device won''t connect to the network since the last update.'),
        ('I''m getting an error code E-4012 when I try to access my dashboard.'),
        ('The download speeds are much slower than what I''m paying for.'),
        ('My email isn''t syncing across my devices anymore.'),
        ('I can''t get the two-factor authentication to work on my account.'),
        ('The software update failed halfway through and now nothing works.'),
        ('I''m having trouble setting up the new router you sent me.'),
        ('My screen keeps freezing when I try to use the video conferencing feature.'),
        ('The API integration stopped working after your last maintenance window.'),
        ('I keep getting timeout errors when uploading files larger than 50MB.'),
        ('The mobile app version 3.2 has a bug where notifications don''t appear.'),
        ('My VPN connection to your service drops during peak hours.')
),
account_issues AS (
    SELECT column1 AS issue FROM VALUES
        ('I need to update the primary email address on my account.'),
        ('I''d like to add another authorized user to my account.'),
        ('Can you help me merge my two accounts into one?'),
        ('I need to change the billing address associated with my account.'),
        ('I want to upgrade my account to the business tier.'),
        ('I need to transfer ownership of this account to my business partner.'),
        ('Can you verify what plan I''m currently on?'),
        ('I''d like to review the security settings on my account.'),
        ('I need to remove an old phone number from my account.'),
        ('Can you help me set up sub-accounts for my team members?'),
        ('I want to change my username but the option is greyed out.'),
        ('I need to update my company information in the account profile.'),
        ('Can you walk me through enabling the enterprise features on my plan?'),
        ('I''d like to review my account activity for the past 30 days.'),
        ('I need to reset my security questions because I forgot the answers.')
),
product_issues AS (
    SELECT column1 AS issue FROM VALUES
        ('I''m interested in learning more about your enterprise package.'),
        ('What are the differences between the Pro and Premium plans?'),
        ('Does your product support integration with Salesforce?'),
        ('I''d like to know if you offer any educational discounts.'),
        ('Can you tell me about the new features released this quarter?'),
        ('What''s included in the add-on analytics module?'),
        ('I''m evaluating your product against a competitor. Can you help me compare?'),
        ('Does your service support multi-region deployment?'),
        ('I''m curious about your API rate limits on the developer plan.'),
        ('Can you explain how the data retention policy works for each tier?'),
        ('I saw an advertisement about a new collaboration tool. Is it available yet?'),
        ('What hardware requirements are needed for the on-premise installation?'),
        ('Do you offer a free trial before committing to an annual subscription?'),
        ('I''m interested in the white-label option for resellers.'),
        ('Can you walk me through the onboarding process for new enterprise clients?')
),
complaint_issues AS (
    SELECT column1 AS issue FROM VALUES
        ('I''ve been on hold for over an hour and this is completely unacceptable.'),
        ('This is the third time I''ve called about the same issue and nobody has fixed it.'),
        ('The service outage last week caused significant problems for my business.'),
        ('I was promised a callback within 24 hours and it''s been three days.'),
        ('Your technician missed the scheduled appointment window without any notice.'),
        ('The quality of service has deteriorated significantly over the past few months.'),
        ('I received a damaged product and the replacement process has been a nightmare.'),
        ('I feel like I''m getting the runaround. Nobody seems to know how to help me.'),
        ('The customer service experience has been extremely frustrating.'),
        ('I was given incorrect information by your previous representative.'),
        ('My data was lost during the migration and nobody is taking responsibility.'),
        ('The automated system keeps disconnecting my calls before I reach a human.'),
        ('I''ve submitted multiple support tickets and none of them have been addressed.'),
        ('The product does not perform as advertised and I feel misled.'),
        ('Your website went down during a critical transaction and I lost my order.')
),
cancel_issues AS (
    SELECT column1 AS issue FROM VALUES
        ('I''d like to cancel my subscription effective immediately.'),
        ('I''m not getting enough value from the service to justify the cost.'),
        ('I''ve found a competitor that offers better features at a lower price.'),
        ('My business needs have changed and I no longer require this service.'),
        ('I want to cancel but I need to know what happens to my stored data.'),
        ('The recent price increase has pushed this beyond my budget.'),
        ('I''m downsizing my operations and need to cut non-essential services.'),
        ('I''d like to cancel my account and get a prorated refund for the remaining months.'),
        ('The product hasn''t lived up to my expectations so I want to end my subscription.'),
        ('I''m moving to a different platform that integrates better with our workflow.'),
        ('I want to close my account but first need to export all my data.'),
        ('I''ve decided to bring this function in-house so I no longer need your service.'),
        ('Can you process a cancellation and confirm there won''t be any early termination fees?'),
        ('I need to cancel before the next billing cycle to avoid being charged again.'),
        ('I''m cancelling because the promised features from the roadmap were never delivered.')
),
-- Category-specific resolutions (8 each)
billing_resolutions AS (
    SELECT column1 AS resolution FROM VALUES
        ('I''ve applied a credit of the disputed amount to your next billing cycle. You should see it reflected within 48 hours.'),
        ('I''ve corrected the billing error and you''ll receive an updated invoice via email shortly.'),
        ('The promotional discount has been applied retroactively. Your adjusted bill will be generated tonight.'),
        ('I''ve set up the automatic payment with the new card ending in 4521. Your next payment is scheduled for the 15th.'),
        ('I''ve escalated the refund request to our billing team. You should receive the refund within 5-7 business days.'),
        ('I''ve locked in your current rate for the next 12 months as promised. I''m sending you a confirmation email now.'),
        ('I''ve waived the late fee as a one-time courtesy and your account is now current.'),
        ('I''ve sent the detailed billing history to your email. It covers all transactions from the past six months.')
),
tech_resolutions AS (
    SELECT column1 AS resolution FROM VALUES
        ('I''ve reset your connection on our end and pushed a firmware update to your device. Please restart it in about 5 minutes.'),
        ('I''ve unlocked your account and sent a password reset link to your registered email address.'),
        ('This is a known issue with the latest release. I''ve enrolled you in the hotfix that rolls out tomorrow.'),
        ('I''ve reconfigured your network settings remotely. Try reconnecting now and let me know if it works.'),
        ('I''m scheduling a technician visit for Thursday between 9am and 12pm to resolve this on-site.'),
        ('I''ve cleared the cache on your profile and the error should be resolved. Please try logging in again.'),
        ('I''ve opened a priority engineering ticket for this issue. Our team will investigate within 24 hours.'),
        ('I''ve walked through the router setup steps and your connection is now active and stable.')
),
account_resolutions AS (
    SELECT column1 AS resolution FROM VALUES
        ('I''ve updated your email address to the new one you provided. A verification link has been sent.'),
        ('The additional user has been added with the permissions you specified. They''ll receive an invitation email.'),
        ('I''ve initiated the account merge. Both accounts will be consolidated within 24 to 48 hours.'),
        ('Your billing address has been updated. All future correspondence will go to the new address.'),
        ('I''ve upgraded your account to the business tier. The new features are available immediately.'),
        ('The ownership transfer paperwork has been emailed to both parties. Once signed, we''ll process it within 2 business days.'),
        ('I''ve confirmed you''re currently on the Professional plan at $79 per month, renewed annually.'),
        ('Your security settings have been updated with the new two-factor authentication method you selected.')
),
product_resolutions AS (
    SELECT column1 AS resolution FROM VALUES
        ('I''ve emailed you a detailed comparison sheet between our plans along with a personalized quote for the enterprise package.'),
        ('The free trial has been activated on your account. You have 14 days to explore all Premium features.'),
        ('Yes, we fully support Salesforce integration. I''m sending you the setup documentation now.'),
        ('I''ve applied the 20 percent educational discount to your account. It''s valid for the duration of your enrollment.'),
        ('I''ve scheduled a product demo with our solutions engineer for next Tuesday at 2pm.'),
        ('The new features you asked about are in beta. I''ve added you to the early access list.'),
        ('I''m connecting you with our partnerships team who can walk you through the white-label program.'),
        ('I''ve sent the API documentation and rate limit details for the developer plan to your email.')
),
complaint_resolutions AS (
    SELECT column1 AS resolution FROM VALUES
        ('I sincerely apologize for the experience. I''ve credited your account $50 and escalated this to our service quality team.'),
        ('I understand your frustration. I''ve created a priority case and assigned a dedicated case manager who will follow up within 4 hours.'),
        ('I''m very sorry about the missed appointment. I''ve rescheduled for the earliest slot tomorrow and added a service credit.'),
        ('I take full responsibility for the miscommunication. I''ve corrected the issue and documented the resolution to prevent this from happening again.'),
        ('I''ve escalated your data recovery request to our engineering team with highest priority. You''ll receive hourly updates.'),
        ('I apologize for the repeated issues. I''ve applied a three-month credit and ensured your case is flagged for executive review.'),
        ('I understand how disruptive this has been. I''ve fast-tracked your replacement shipment with overnight delivery at no charge.'),
        ('I''ve compiled all your previous tickets and assigned them to a senior specialist who will contact you by end of day.')
),
cancel_resolutions AS (
    SELECT column1 AS resolution FROM VALUES
        ('I''ve processed your cancellation. Your service will remain active until the end of the current billing period on May 15th.'),
        ('Before I process the cancellation, I can offer you a 40 percent discount for the next three months if you''d like to reconsider.'),
        ('I''ve initiated the cancellation and your prorated refund of $45.50 will be returned to your card within 7 business days.'),
        ('I''ve started the data export process. You''ll receive a download link within 24 hours, and then we''ll proceed with the account closure.'),
        ('Your cancellation has been confirmed. There are no early termination fees on your plan. I''m sending a confirmation email now.'),
        ('I understand. I''ve cancelled the subscription and removed your payment method. You can reactivate anytime within 90 days without losing your data.'),
        ('I''ve processed the cancellation request. Your account will be downgraded to the free tier so you retain read-only access to your data.'),
        ('The cancellation is complete. I''ve also submitted your feedback about the undelivered roadmap features to our product team.')
),
-- Agent closings (6 variations)
closings AS (
    SELECT column1 AS closing FROM VALUES
        ('Is there anything else I can help you with today?'),
        ('I hope that resolves everything. Don''t hesitate to call back if you need anything else.'),
        ('Thank you for your patience. Have a great rest of your day.'),
        ('I''m glad I could help. Please reach out if anything else comes up.'),
        ('We appreciate your business. Is there anything else before I let you go?'),
        ('Thank you for being a valued customer. Take care.')
),
-- Generate 3000 rows with random component selections
row_gen AS (
    SELECT
        SEQ4() AS row_num,
        UNIFORM(1, 6, RANDOM()) AS cat_id,
        UNIFORM(1, 10, RANDOM()) AS greeting_id,
        UNIFORM(1, 8, RANDOM()) AS agent_id,
        UNIFORM(1, 15, RANDOM()) AS issue_id,
        UNIFORM(1, 8, RANDOM()) AS resolution_id,
        UNIFORM(1, 6, RANDOM()) AS closing_id
    FROM TABLE(GENERATOR(ROWCOUNT => 3000))
)
SELECT
    g.greeting || ' ' || ao.agent_opening || ' Customer: ' ||
    CASE r.cat_id
        WHEN 1 THEN bi.issue
        WHEN 2 THEN ti.issue
        WHEN 3 THEN ai.issue
        WHEN 4 THEN pi.issue
        WHEN 5 THEN ci.issue
        WHEN 6 THEN cai.issue
    END
    || ' Agent: ' ||
    CASE r.cat_id
        WHEN 1 THEN br.resolution
        WHEN 2 THEN tr.resolution
        WHEN 3 THEN ar.resolution
        WHEN 4 THEN pr.resolution
        WHEN 5 THEN cr.resolution
        WHEN 6 THEN car.resolution
    END
    || ' ' || cl.closing
    AS TRANSCRIPT,
    CASE r.cat_id
        WHEN 1 THEN 'Billing'
        WHEN 2 THEN 'Technical Support'
        WHEN 3 THEN 'Account Management'
        WHEN 4 THEN 'Product Inquiry'
        WHEN 5 THEN 'Complaint'
        WHEN 6 THEN 'Cancellation'
    END AS CATEGORY
FROM row_gen r
JOIN (SELECT greeting, ROW_NUMBER() OVER (ORDER BY greeting) AS rn FROM greetings) g ON g.rn = r.greeting_id
JOIN (SELECT agent_opening, ROW_NUMBER() OVER (ORDER BY agent_opening) AS rn FROM agent_openings) ao ON ao.rn = r.agent_id
LEFT JOIN (SELECT issue, ROW_NUMBER() OVER (ORDER BY issue) AS rn FROM billing_issues) bi ON r.cat_id = 1 AND bi.rn = r.issue_id
LEFT JOIN (SELECT issue, ROW_NUMBER() OVER (ORDER BY issue) AS rn FROM tech_issues) ti ON r.cat_id = 2 AND ti.rn = r.issue_id
LEFT JOIN (SELECT issue, ROW_NUMBER() OVER (ORDER BY issue) AS rn FROM account_issues) ai ON r.cat_id = 3 AND ai.rn = r.issue_id
LEFT JOIN (SELECT issue, ROW_NUMBER() OVER (ORDER BY issue) AS rn FROM product_issues) pi ON r.cat_id = 4 AND pi.rn = r.issue_id
LEFT JOIN (SELECT issue, ROW_NUMBER() OVER (ORDER BY issue) AS rn FROM complaint_issues) ci ON r.cat_id = 5 AND ci.rn = r.issue_id
LEFT JOIN (SELECT issue, ROW_NUMBER() OVER (ORDER BY issue) AS rn FROM cancel_issues) cai ON r.cat_id = 6 AND cai.rn = r.issue_id
LEFT JOIN (SELECT resolution, ROW_NUMBER() OVER (ORDER BY resolution) AS rn FROM billing_resolutions) br ON r.cat_id = 1 AND br.rn = r.resolution_id
LEFT JOIN (SELECT resolution, ROW_NUMBER() OVER (ORDER BY resolution) AS rn FROM tech_resolutions) tr ON r.cat_id = 2 AND tr.rn = r.resolution_id
LEFT JOIN (SELECT resolution, ROW_NUMBER() OVER (ORDER BY resolution) AS rn FROM account_resolutions) ar ON r.cat_id = 3 AND ar.rn = r.resolution_id
LEFT JOIN (SELECT resolution, ROW_NUMBER() OVER (ORDER BY resolution) AS rn FROM product_resolutions) pr ON r.cat_id = 4 AND pr.rn = r.resolution_id
LEFT JOIN (SELECT resolution, ROW_NUMBER() OVER (ORDER BY resolution) AS rn FROM complaint_resolutions) cr ON r.cat_id = 5 AND cr.rn = r.resolution_id
LEFT JOIN (SELECT resolution, ROW_NUMBER() OVER (ORDER BY resolution) AS rn FROM cancel_resolutions) car ON r.cat_id = 6 AND car.rn = r.resolution_id
JOIN (SELECT closing, ROW_NUMBER() OVER (ORDER BY closing) AS rn FROM closings) cl ON cl.rn = r.closing_id;

-- Step 4: Create training/validation views (80/20 split)
CREATE OR REPLACE VIEW FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.FT_TRAINING_DATA AS
SELECT
    TRANSCRIPT_ID,
    'Classify the following customer service call transcript into exactly one of these categories: Billing, Technical Support, Account Management, Product Inquiry, Complaint, Cancellation.\n\nTranscript:\n' || TRANSCRIPT AS prompt,
    CATEGORY AS completion
FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.RAW_TRANSCRIPTS
WHERE MOD(TRANSCRIPT_ID, 5) != 0;

CREATE OR REPLACE VIEW FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.FT_VALIDATION_DATA AS
SELECT
    TRANSCRIPT_ID,
    'Classify the following customer service call transcript into exactly one of these categories: Billing, Technical Support, Account Management, Product Inquiry, Complaint, Cancellation.\n\nTranscript:\n' || TRANSCRIPT AS prompt,
    CATEGORY AS completion
FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.RAW_TRANSCRIPTS
WHERE MOD(TRANSCRIPT_ID, 5) = 0;

-- Step 5: Verify the data
SELECT 'RAW_TRANSCRIPTS' AS object, COUNT(*) AS row_count FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.RAW_TRANSCRIPTS
UNION ALL
SELECT 'TRAINING_DATA', COUNT(*) FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.FT_TRAINING_DATA
UNION ALL
SELECT 'VALIDATION_DATA', COUNT(*) FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.FT_VALIDATION_DATA;

SELECT CATEGORY, COUNT(*) AS cnt
FROM FINETUNING_AI_COMPLETE.CALL_TRANSCRIPTS.RAW_TRANSCRIPTS
GROUP BY CATEGORY
ORDER BY CATEGORY;