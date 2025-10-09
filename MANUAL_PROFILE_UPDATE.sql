-- Manual Profile Update Script
-- Use this to manually update a profile with all the data
-- Replace the values below with actual user data

-- Example for a Student:
UPDATE profiles 
SET 
  campus = 'Makerere University',
  year_of_study = 'Year 2',
  course = 'Computer Science',
  phone_number = '+256700000000',
  gender = 'Male',
  interests = ARRAY['Technology', 'Sports', 'Music'],
  updated_at = NOW()
WHERE email = 'user@example.com';

-- Example for a Hostel Provider:
-- UPDATE profiles 
-- SET 
--   business_name = 'Campus Hostels Ltd',
--   primary_phone = '+256700000001',
--   secondary_phone = '+256700000002',
--   location_name = 'Near Campus',
--   address = '123 University Road',
--   phone_number = '+256700000001',
--   updated_at = NOW()
-- WHERE email = 'hostel@example.com';

-- Check the updated profile:
SELECT * FROM profiles WHERE email = 'user@example.com';
