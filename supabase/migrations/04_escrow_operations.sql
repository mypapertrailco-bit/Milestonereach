-- 04_escrow_operations.sql
-- Functions to handle movement of funds between wallet balance and campaign escrow

-- 1. Function to hold funds in escrow when a campaign is launched
CREATE OR REPLACE FUNCTION public.hold_campaign_escrow(
    p_business_id UUID,
    p_campaign_id UUID,
    p_amount DECIMAL(12,2)
)
RETURNS JSONB AS $$
DECLARE
    v_current_balance DECIMAL(12,2);
BEGIN
    -- Check current balance
    SELECT balance INTO v_current_balance 
    FROM public.wallets 
    WHERE user_id = p_business_id 
    FOR UPDATE; -- Lock the row for transaction safety

    IF v_current_balance IS NULL OR v_current_balance < p_amount THEN
        RETURN jsonb_build_object('success', false, 'error', 'Insufficient balance in wallet');
    END IF;

    -- 1. Deduct from wallet balance and move to locked_amount
    UPDATE public.wallets 
    SET balance = balance - p_amount,
        locked_amount = locked_amount + p_amount,
        updated_at = NOW()
    WHERE user_id = p_business_id;

    -- 2. Create a wallet transaction record
    INSERT INTO public.wallet_transactions (
        user_id, 
        amount, 
        type, 
        status, 
        description, 
        reference_id
    )
    VALUES (
        p_business_id, 
        -p_amount, -- Negative because it's leaving the 'available' balance
        'escrow_hold', 
        'completed', 
        'Funds held for campaign escrow', 
        p_campaign_id::TEXT
    );

    -- 3. Update the campaign's escrow_balance
    UPDATE public.campaigns
    SET escrow_balance = escrow_balance + p_amount,
        status = 'active'
    WHERE id = p_campaign_id;

    RETURN jsonb_build_object('success', true, 'new_balance', v_current_balance - p_amount);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Function to release escrow funds to a creator
CREATE OR REPLACE FUNCTION public.release_escrow_to_creator(
    p_business_id UUID,
    p_creator_id UUID,
    p_campaign_id UUID,
    p_amount DECIMAL(12,2)
)
RETURNS JSONB AS $$
BEGIN
    -- 1. Deduct from business's locked_amount
    UPDATE public.wallets 
    SET locked_amount = locked_amount - p_amount,
        updated_at = NOW()
    WHERE user_id = p_business_id;

    -- 2. Add to creator's available balance
    INSERT INTO public.wallets (user_id, balance)
    VALUES (p_creator_id, p_amount)
    ON CONFLICT (user_id) DO UPDATE
    SET balance = wallets.balance + p_amount,
        updated_at = NOW();

    -- 3. Record transaction for business (escrow release)
    INSERT INTO public.wallet_transactions (user_id, amount, type, status, description, reference_id)
    VALUES (p_business_id, 0, 'escrow_release', 'completed', 'Escrow funds released to creator', p_campaign_id::TEXT);

    -- 4. Record transaction for creator (payout)
    INSERT INTO public.wallet_transactions (user_id, amount, type, status, description, reference_id)
    VALUES (p_creator_id, p_amount, 'payout', 'completed', 'Payout received from campaign', p_campaign_id::TEXT);

    -- 5. Update campaign's escrow_balance
    UPDATE public.campaigns
    SET escrow_balance = escrow_balance - p_amount
    WHERE id = p_campaign_id;

    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.hold_campaign_escrow IS 'Moves funds from wallet balance to campaign escrow.';
COMMENT ON FUNCTION public.release_escrow_to_creator IS 'Releases escrowed funds to a creator upon milestone completion.';
