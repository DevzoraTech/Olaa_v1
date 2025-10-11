-- Create marketplace_item_views table for tracking individual user views
-- This prevents users from incrementing view counts multiple times for the same item

CREATE TABLE IF NOT EXISTS marketplace_item_views (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  item_id UUID REFERENCES marketplace_items(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create unique constraint to prevent duplicate views from the same user
CREATE UNIQUE INDEX IF NOT EXISTS marketplace_item_views_unique_user_item 
ON marketplace_item_views(item_id, user_id);

-- Enable RLS on marketplace_item_views
ALTER TABLE marketplace_item_views ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for marketplace_item_views
CREATE POLICY "Users can view their own view records" ON marketplace_item_views
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own view records" ON marketplace_item_views
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create index for better performance on queries
CREATE INDEX IF NOT EXISTS marketplace_item_views_item_id_idx 
ON marketplace_item_views(item_id);

CREATE INDEX IF NOT EXISTS marketplace_item_views_user_id_idx 
ON marketplace_item_views(user_id);

CREATE INDEX IF NOT EXISTS marketplace_item_views_viewed_at_idx 
ON marketplace_item_views(viewed_at);
