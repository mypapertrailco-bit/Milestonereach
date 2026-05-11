-- MilestoneReach: Chat & Messaging Schema

-- Create the messages table
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  campaign_id UUID REFERENCES campaigns(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policies for security
-- Users can read messages where they are either the sender or the receiver
CREATE POLICY "Users can read their own messages" 
ON messages FOR SELECT 
USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- Users can send messages
CREATE POLICY "Users can send messages" 
ON messages FOR INSERT 
WITH CHECK (auth.uid() = sender_id);

-- Mark messages as read
CREATE POLICY "Users can update their received messages to read" 
ON messages FOR UPDATE 
USING (auth.uid() = receiver_id)
WITH CHECK (is_read = TRUE);

-- Realtime: Enable realtime for the messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
