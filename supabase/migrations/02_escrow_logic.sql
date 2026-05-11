-- MilestoneReach: Escrow Release Logic
-- This function is called when an admin approves a milestone submission.

CREATE OR REPLACE FUNCTION release_escrow_to_creator(p_submission_id UUID)
RETURNS VOID AS $$
DECLARE
  v_creator_id UUID;
  v_campaign_id UUID;
  v_milestone_id UUID;
  v_payout_amount DECIMAL;
BEGIN
  -- 1. Fetch details from the submission
  SELECT 
    ms.creator_id, 
    ms.campaign_id, 
    ms.milestone_id,
    cm.payout_amount
  INTO 
    v_creator_id, 
    v_campaign_id, 
    v_milestone_id,
    v_payout_amount
  FROM milestone_submissions ms
  JOIN campaign_milestones cm ON ms.milestone_id = cm.id
  WHERE ms.id = p_submission_id AND ms.status = 'Approved';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Submission not found or not yet approved.';
  END IF;

  -- 2. Create a transaction to move funds from Escrow to Available
  -- First, record the debit from Escrow
  INSERT INTO wallet_transactions (
    user_id, 
    campaign_id, 
    amount, 
    type, 
    status
  ) VALUES (
    v_creator_id,
    v_campaign_id,
    -v_payout_amount,
    'escrow_release',
    'Completed'
  );

  -- Second, record the credit to Available Balance
  INSERT INTO wallet_transactions (
    user_id, 
    campaign_id, 
    amount, 
    type, 
    status
  ) VALUES (
    v_creator_id,
    v_campaign_id,
    v_payout_amount,
    'payout',
    'Completed'
  );

  -- 3. Update the milestone status for this participant
  UPDATE campaign_participants
  SET milestones_completed = milestones_completed + 1
  WHERE creator_id = v_creator_id AND campaign_id = v_campaign_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
