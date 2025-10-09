-- Test Profile Data Insertion
-- This script tests if we can manually insert profile data with all fields
-- NOTE: This will only work if you have actual users in auth.users table

-- First, let's see what users exist in auth.users
SELECT id, email FROM auth.users ORDER BY created_at DESC LIMIT 5;

-- Test Student Profile (replace the ID with an actual user ID from above)
-- INSERT INTO profiles (
--   id,
--   email,
--   first_name,
--   last_name,
--   primary_role,
--   campus,
--   year_of_study,
--   course,
--   phone_number,
--   gender,
--   interests,
--   is_verified,
--   is_active,
--   timezone,
--   language,
--   notification_preferences,
--   privacy_settings,
--   created_at,
--   updated_at
-- ) VALUES (
--   'REPLACE_WITH_ACTUAL_USER_ID',
--   'test-student@example.com',
--   'John',
--   'Doe',
--   'Student',
--   'Makerere University',
--   'Year 2',
--   'Computer Science',
--   '+256700000000',
--   'Male',
--   ARRAY['Technology', 'Sports', 'Music'],
--   false,
--   true,
--   'UTC',
--   'en',
--   '{}',
--   '{}',
--   NOW(),
--   NOW()
-- );

-- Test Hostel Provider Profile (commented out - use actual user ID)
-- INSERT INTO profiles (
--   id,
--   email,
--   first_name,
--   last_name,
--   primary_role,
--   business_name,
--   primary_phone,
--   secondary_phone,
--   location_name,
--   address,
--   phone_number,
--   is_verified,
--   is_active,
--   timezone,
--   language,
--   notification_preferences,
--   privacy_settings,
--   created_at,
--   updated_at
-- ) VALUES (
--   'REPLACE_WITH_ACTUAL_USER_ID',
--   'test-hostel@example.com',
--   'Jane',
--   'Smith',
--   'Hostel Provider',
--   'Campus Hostels Ltd',
--   '+256700000001',
--   '+256700000002',
--   'Near Campus',
--   '123 University Road',
--   '+256700000001',
--   false,
--   true,
--   'UTC',
--   'en',
--   '{}',
--   '{}',
--   NOW(),
--   NOW()
-- );

-- Test Event Organizer Profile (commented out - use actual user ID)
-- INSERT INTO profiles (
--   id,
--   email,
--   first_name,
--   last_name,
--   primary_role,
--   organization_name,
--   organization_type,
--   organization_description,
--   organization_website,
--   phone_number,
--   is_verified,
--   is_active,
--   timezone,
--   language,
--   notification_preferences,
--   privacy_settings,
--   created_at,
--   updated_at
-- ) VALUES (
--   'REPLACE_WITH_ACTUAL_USER_ID',
--   'test-organizer@example.com',
--   'Mike',
--   'Johnson',
--   'Event Organizer',
--   'Campus Events Co',
--   'Student Organization',
--   'We organize amazing campus events',
--   'https://campus-events.com',
--   '+256700000003',
--   false,
--   true,
--   'UTC',
--   'en',
--   '{}',
--   '{}',
--   NOW(),
--   NOW()
-- );

-- Test Promoter Profile (commented out - use actual user ID)
-- INSERT INTO profiles (
--   id,
--   email,
--   first_name,
--   last_name,
--   primary_role,
--   agency_name,
--   agency_type,
--   agency_description,
--   agency_website,
--   phone_number,
--   is_verified,
--   is_active,
--   timezone,
--   language,
--   notification_preferences,
--   privacy_settings,
--   created_at,
--   updated_at
-- ) VALUES (
--   'REPLACE_WITH_ACTUAL_USER_ID',
--   'test-promoter@example.com',
--   'Sarah',
--   'Wilson',
--   'Promoter',
--   'Campus Promotions',
--   'Event Promotion Agency',
--   'We promote campus events and parties',
--   'https://campus-promotions.com',
--   '+256700000004',
--   false,
--   true,
--   'UTC',
--   'en',
--   '{}',
--   '{}',
--   NOW(),
--   NOW()
-- );

-- Check all test profiles
SELECT 
  email,
  first_name,
  last_name,
  primary_role,
  campus,
  business_name,
  organization_name,
  agency_name
FROM profiles 
WHERE email LIKE 'test-%@example.com'
ORDER BY created_at DESC;
