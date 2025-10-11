-- Migration: Drop and recreate messages table with proper schema
-- This ensures we have all the fields needed for a complete chat system

-- Drop existing messages table and all related objects
DROP TRIGGER IF EXISTS trigger_update_chat_on_message ON messages;
DROP FUNCTION IF EXISTS update_chat_on_message();
DROP TABLE IF EXISTS messages CASCADE;

-- Recreate messages table with comprehensive schema
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'video', 'file', 'voice', 'link', 'location', 'contact')),
  
  -- File attachment fields
  file_url TEXT,
  file_name TEXT,
  file_size INTEGER,
  file_type TEXT, -- MIME type
  
  -- Message threading/reply
  reply_to_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  
  -- Message status
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMP WITH TIME ZONE,
  
  -- Delivery status
  is_delivered BOOLEAN DEFAULT FALSE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  
  -- Read status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_type ON messages(type);
CREATE INDEX idx_messages_reply_to ON messages(reply_to_message_id);

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for messages table
CREATE POLICY "Users can view messages in their chats" ON messages
  FOR SELECT USING (
    chat_id IN (
      SELECT chat_id FROM chat_participants 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send messages to chats they're in" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid() AND
    chat_id IN (
      SELECT chat_id FROM chat_participants 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can edit their own messages" ON messages
  FOR UPDATE USING (
    sender_id = auth.uid() AND
    chat_id IN (
      SELECT chat_id FROM chat_participants 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own messages" ON messages
  FOR DELETE USING (
    sender_id = auth.uid() AND
    chat_id IN (
      SELECT chat_id FROM chat_participants 
      WHERE user_id = auth.uid()
    )
  );

-- Function to update chat's updated_at and last_message_at when a message is inserted
CREATE OR REPLACE FUNCTION update_chat_on_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chats 
  SET 
    updated_at = NOW(),
    last_message_at = NEW.created_at,
    last_message = CASE 
      WHEN NEW.type = 'text' THEN NEW.message
      WHEN NEW.type = 'image' THEN '📷 Image'
      WHEN NEW.type = 'video' THEN '🎥 Video'
      WHEN NEW.type = 'file' THEN '📎 File'
      WHEN NEW.type = 'voice' THEN '🎤 Voice message'
      WHEN NEW.type = 'link' THEN '🔗 Link'
      WHEN NEW.type = 'location' THEN '📍 Location'
      WHEN NEW.type = 'contact' THEN '👤 Contact'
      ELSE 'Message'
    END,
    last_message_sender_id = NEW.sender_id
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update chat timestamps when messages are inserted
CREATE TRIGGER trigger_update_chat_on_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_chat_on_message();

-- Function to update message read status
CREATE OR REPLACE FUNCTION mark_message_as_read(message_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
  chat_uuid UUID;
BEGIN
  -- Get the chat_id for this message
  SELECT chat_id INTO chat_uuid FROM messages WHERE id = message_uuid;
  
  -- Check if user is participant in this chat
  IF NOT EXISTS (
    SELECT 1 FROM chat_participants 
    WHERE chat_id = chat_uuid AND user_id = user_uuid
  ) THEN
    RETURN FALSE;
  END IF;
  
  -- Update message read status
  UPDATE messages 
  SET 
    is_read = TRUE,
    read_at = NOW()
  WHERE id = message_uuid AND sender_id != user_uuid;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark all messages in a chat as read for a user
CREATE OR REPLACE FUNCTION mark_chat_messages_as_read(chat_uuid UUID, user_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  -- Check if user is participant in this chat
  IF NOT EXISTS (
    SELECT 1 FROM chat_participants 
    WHERE chat_id = chat_uuid AND user_id = user_uuid
  ) THEN
    RETURN 0;
  END IF;
  
  -- Update all unread messages in this chat
  UPDATE messages 
  SET 
    is_read = TRUE,
    read_at = NOW()
  WHERE chat_id = chat_uuid 
    AND sender_id != user_uuid 
    AND is_read = FALSE;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION mark_message_as_read(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION mark_chat_messages_as_read(UUID, UUID) TO authenticated;

-- Add missing columns to chats table if they don't exist
ALTER TABLE chats ADD COLUMN IF NOT EXISTS last_message TEXT;
ALTER TABLE chats ADD COLUMN IF NOT EXISTS last_message_sender_id UUID REFERENCES auth.users(id);

-- Create index for last_message_sender_id
CREATE INDEX IF NOT EXISTS idx_chats_last_message_sender ON chats(last_message_sender_id);

-- Verify the new table structure
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns 
WHERE table_name = 'messages' 
ORDER BY ordinal_position;
