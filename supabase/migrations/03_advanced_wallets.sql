-- 03_advanced_wallets.sql
-- Enhancing the wallet system with balance tracking and automated triggers

-- 1. Create a dedicated wallets table for quick balance lookups
CREATE TABLE IF NOT EXISTS public.wallets (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    balance DECIMAL(12,2) DEFAULT 0.00,
    locked_amount DECIMAL(12,2) DEFAULT 0.00, -- Amount in escrow
    currency TEXT DEFAULT 'INR',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Add Row Level Security to wallets
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own wallet"
    ON public.wallets FOR SELECT
    USING (auth.uid() = user_id);

-- 3. Enhance wallet_transactions with more statuses
-- Since transaction_type already exists, we'll just ensure status is handled well
-- Note: In a real migration, we might use ALTER TYPE, but here we'll just update the table column logic

-- 4. Function to update wallet balance on transaction completion
CREATE OR REPLACE FUNCTION public.process_wallet_transaction()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update balance if the transaction is 'completed' or 'approved'
    IF (NEW.status = 'completed' OR NEW.status = 'approved') AND (OLD.status IS NULL OR OLD.status = 'pending') THEN
        
        -- Insert or Update wallet
        INSERT INTO public.wallets (user_id, balance)
        VALUES (NEW.user_id, NEW.amount)
        ON CONFLICT (user_id) DO UPDATE
        SET balance = wallets.balance + EXCLUDED.balance,
            updated_at = NOW();
            
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Trigger for wallet_transactions
CREATE TRIGGER on_wallet_transaction_status_change
    AFTER INSERT OR UPDATE OF status ON public.wallet_transactions
    FOR EACH ROW
    EXECUTE PROCEDURE public.process_wallet_transaction();

-- 6. Helper function to initialize wallet on user signup (optional but recommended)
CREATE OR REPLACE FUNCTION public.handle_new_user_wallet()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.wallets (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create wallet when a user profile is created
-- (Assuming profiles are created on auth.users signup)
-- If you have a profiles table, you can link it there. 
-- For now, let's just make sure we have a way to manually sync if needed.

COMMENT ON TABLE public.wallets IS 'Stores the real-time balance for each user.';
COMMENT ON COLUMN public.wallet_transactions.reference_id IS 'External reference like UPI Transaction ID or Internal Reference.';
