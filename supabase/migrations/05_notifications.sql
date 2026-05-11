-- 05_notifications.sql
-- In-app notification system for MilestoneReach

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info', -- info, success, warning, payment
    is_read BOOLEAN DEFAULT FALSE,
    link TEXT, -- Optional link to a screen (e.g. /wallet or /campaign/123)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications (mark as read)"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- Automated Notification Triggers

-- 1. Notify user when a wallet transaction is approved/completed
CREATE OR REPLACE FUNCTION public.notify_on_transaction_update()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'completed' OR NEW.status = 'approved') AND (OLD.status = 'pending') THEN
        INSERT INTO public.notifications (user_id, title, message, type, link)
        VALUES (
            NEW.user_id, 
            'Payment Approved', 
            'Your deposit/withdrawal of ₹' || NEW.amount || ' has been processed successfully.',
            'payment',
            '/wallet'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_notify_transaction
    AFTER UPDATE OF status ON public.wallet_transactions
    FOR EACH ROW
    EXECUTE PROCEDURE public.notify_on_transaction_update();

-- 2. Notify creator when escrow is released (payout received)
-- We can add this to the release_escrow_to_creator function or use a trigger on wallet_transactions for type='payout'
CREATE OR REPLACE FUNCTION public.notify_on_payout()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.type = 'payout' AND NEW.status = 'completed') THEN
        INSERT INTO public.notifications (user_id, title, message, type, link)
        VALUES (
            NEW.user_id, 
            'Payout Received! 💰', 
            'Congratulations! You have received a payout of ₹' || NEW.amount || ' for your milestone completion.',
            'success',
            '/wallet'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_notify_payout
    AFTER INSERT ON public.wallet_transactions
    FOR EACH ROW
    EXECUTE PROCEDURE public.notify_on_payout();

COMMENT ON TABLE public.notifications IS 'Stores in-app notifications for users.';
