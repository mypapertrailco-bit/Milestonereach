-- MilestoneReach Database Schema
-- Supabase PostgreSQL

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- USERS & PROFILES
-- ==========================================

-- users table is managed by Supabase Auth (auth.users)
-- We use creator_profiles and business_profiles to store role-specific data

CREATE TABLE public.creator_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    phone_number TEXT,
    bio TEXT,
    instagram_handle TEXT,
    follower_count INT DEFAULT 0,
    engagement_rate DECIMAL(5,2) DEFAULT 0.0,
    niche_tags TEXT[] DEFAULT '{}',
    
    -- Verification & Trust
    is_verified BOOLEAN DEFAULT FALSE,
    id_verified BOOLEAN DEFAULT FALSE,
    trust_score INT DEFAULT 50, -- 0 to 100 scale
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.business_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    company_name TEXT NOT NULL,
    logo_url TEXT,
    website_url TEXT,
    industry TEXT,
    gstin TEXT,
    company_email TEXT,
    
    -- Verification & Trust
    is_verified BOOLEAN DEFAULT FALSE,
    trust_score INT DEFAULT 50,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- CAMPAIGNS
-- ==========================================

CREATE TYPE campaign_status AS ENUM ('draft', 'active', 'paused', 'completed', 'cancelled');

CREATE TABLE public.campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID REFERENCES public.business_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    cover_image_url TEXT,
    niche_category TEXT,
    content_guidelines TEXT,
    
    -- Financials & Targets
    total_budget DECIMAL(10,2) NOT NULL,
    escrow_balance DECIMAL(10,2) DEFAULT 0.0,
    max_creators INT NOT NULL,
    
    status campaign_status DEFAULT 'draft',
    due_date TIMESTAMPTZ NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.campaign_milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID REFERENCES public.campaigns(id) ON DELETE CASCADE,
    target_impressions INT NOT NULL,
    reward_amount DECIMAL(10,2) NOT NULL,
    bonus_incentive DECIMAL(10,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- PARTICIPANTS & SUBMISSIONS
-- ==========================================

CREATE TYPE participation_status AS ENUM ('pending', 'accepted', 'in_progress', 'under_review', 'completed', 'rejected');

CREATE TABLE public.campaign_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID REFERENCES public.campaigns(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES public.creator_profiles(id) ON DELETE CASCADE,
    status participation_status DEFAULT 'pending',
    
    -- Metrics achieved
    current_impressions INT DEFAULT 0,
    earned_amount DECIMAL(10,2) DEFAULT 0.0,
    
    -- Proof submissions
    post_url TEXT,
    proof_screenshots TEXT[] DEFAULT '{}',
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(campaign_id, creator_id)
);

-- ==========================================
-- WALLET & PAYMENTS
-- ==========================================

CREATE TYPE transaction_type AS ENUM ('deposit', 'escrow_hold', 'escrow_release', 'payout', 'withdrawal', 'refund');

CREATE TABLE public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    amount DECIMAL(10,2) NOT NULL,
    type transaction_type NOT NULL,
    description TEXT,
    reference_id TEXT, -- E.g. Razorpay Payment ID or Campaign ID
    status TEXT DEFAULT 'completed',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.withdrawals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    creator_id UUID REFERENCES public.creator_profiles(id),
    amount DECIMAL(10,2) NOT NULL,
    bank_account_details JSONB,
    status TEXT DEFAULT 'pending', -- pending, processed, failed
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- SECURITY & TRUST
-- ==========================================

CREATE TABLE public.fraud_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    reason TEXT NOT NULL,
    severity_level INT DEFAULT 1, -- 1=Low, 5=Critical
    metadata JSONB,
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

ALTER TABLE public.creator_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_participants ENABLE ROW LEVEL SECURITY;

-- Creators can read all active campaigns
CREATE POLICY "Anyone can view active campaigns"
    ON public.campaigns FOR SELECT
    USING (status = 'active');

-- Businesses can CRUD their own campaigns
CREATE POLICY "Businesses manage their campaigns"
    ON public.campaigns FOR ALL
    USING (auth.uid() = business_id);

-- Creators can view/update their own profile
CREATE POLICY "Users manage own profile"
    ON public.creator_profiles FOR ALL
    USING (auth.uid() = id);

-- ==========================================
-- TRIGGERS & FUNCTIONS
-- ==========================================

-- Function to update 'updated_at' column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_creator_profiles_modtime
    BEFORE UPDATE ON public.creator_profiles
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
    
CREATE TRIGGER update_campaigns_modtime
    BEFORE UPDATE ON public.campaigns
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
