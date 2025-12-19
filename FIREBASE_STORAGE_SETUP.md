# Firebase Storage Setup for Profile Pictures

## Required Firebase Storage Rules

To enable profile picture uploads, you need to update your Firebase Storage security rules.

### Steps:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Storage** → **Rules**
4. Replace the existing rules with the following:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to read all files
    match /{allPaths=**} {
      allow read: if request.auth != null;
    }
    
    // Allow users to upload and manage their own profile pictures
    match /profile_pictures/{userId}/{allPaths=**} {
      allow write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
  }
}
```

5. Click **Publish** to save the rules

## What These Rules Do:
- ✅ Authenticated users can read all files
- ✅ Users can only upload/modify their own profile pictures (based on their UID)
- ✅ Users can only upload to `/profile_pictures/{their-uid}/`
- ❌ Prevents unauthorized access and data manipulation

## Troubleshooting:
- If upload still fails, check the **Firestore Rules** didn't overwrite Storage Rules
- Ensure your user is authenticated before uploading
- Check Firebase Console Logs for specific permission errors
