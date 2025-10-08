# Community App - Design Specification

**Version:** 1.0
**Last Updated:** 2025-10-08
**Design Source:** Provided screenshots

---

## Color Palette

### Primary Colors
```dart
// Deep Purple/Navy (Header, Primary Actions)
primary: Color(0xFF2E2750)

// Light Purple/Lavender (Backgrounds, Cards)
background: Color(0xFFE8E4F3)
surface: Color(0xFFF5F3FA)

// Accent Blue (Links, Tags, Highlights)
accent: Color(0xFF4A9FE8)

// White
onPrimary: Color(0xFFFFFFFF)
```

### Semantic Colors
```dart
// Text
textPrimary: Color(0xFF1A1A1A)      // Headings, primary text
textSecondary: Color(0xFF757575)    // Timestamps, secondary info

// Interactions
like: Color(0xFF4A9FE8)             // Like icon blue
comment: Color(0xFF4A9FE8)          // Comment icon blue
unread: Color(0xFFE85050)           // Red dot indicator

// Buttons
buttonPrimary: Color(0xFF2E2750)    // Dark purple
buttonSecondary: Color(0xFFE8E4F3) // Light lavender
```

---

## Typography

### Font Family
**Primary:** System Default (SF Pro on iOS, Roboto on Android)

### Text Styles

```dart
// Headers
appBarTitle: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Colors.white,
)

// Body Text
postTitle: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1A1A1A),
)

postContent: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color(0xFF1A1A1A),
)

userName: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1A1A1A),
)

timestamp: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0xFF757575),
)

groupTag: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Color(0xFF4A9FE8),
)

// Profile
profileName: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1A1A1A),
)

profileAddress: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color(0xFF757575),
)

profileBio: TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: Color(0xFF1A1A1A),
  height: 1.4,
)
```

---

## Component Specifications

### 1. App Bar (Message Feed)

**Height:** 120px (including safe area)

**Components:**
- User avatar (top-left, 48x48px, circular)
- Title: "Community" (centered, white, 24px bold)
- Status bar spacing

**Background:** Gradient or solid `Color(0xFF2E2750)`

---

### 2. Search Bar

**Dimensions:** Full-width with 16px horizontal padding

**Style:**
- Background: Light lavender `Color(0xFFE8E4F3)`
- Border radius: 12px
- Height: 48px
- Placeholder: "Search in community feed" (gray)
- Leading icon: Search icon (gray)
- Trailing icon: Filter icon (white on dark purple background)

---

### 3. Tab Navigation

**Style:**
- Background: White/light surface
- Active tab: Blue underline, blue text
- Inactive tab: Gray text
- Font size: 16px, medium weight
- Indicator height: 3px
- Tab padding: 16px vertical, 20px horizontal

**Tabs (Messaging):**
- All posts
- Groups (or Announcements - TBD)

---

### 4. Message Card

**Dimensions:**
- Width: Full-width with 16px horizontal padding
- Padding: 16px internal padding
- Margin: 12px bottom spacing

**Style:**
- Background: White
- Border radius: 12px
- Shadow: Subtle elevation (2dp)

**Components:**
- **Avatar:** 48x48px, circular, left-aligned
- **Username:** 16px bold, black
- **Group tag:** "in [Group]" - 14px, blue
- **Timestamp:** "DD Month HH:MM" - 14px, gray, below username
- **Post title:** 18px bold, black
- **Post content:** 16px regular (if applicable)
- **Interactions bar:**
  - Like icon (blue) + count + user avatars (24x24px, overlapping)
  - Comment icon (blue) + count
  - Positioned at bottom of card
- **Menu button:** Three dots (top-right)
- **Unread indicator:** Red dot (8px, top-right corner)

**Layout:**
```
┌────────────────────────────────────┐
│ [Avatar] Johannes Schwar...  [···] │
│          in Sport            (•)    │
│          09 February 09:18          │
│                                     │
│ Who is up for running tonight?     │
│                                     │
│ 👍 3 [🧑🧑🧑] 💬 8                  │
└────────────────────────────────────┘
```

---

### 5. User Profile Screen

**Layout:**

**Cover Photo:**
- Height: 220px
- Full-width
- Image fit: Cover

**Avatar:**
- Size: 120x120px
- Border: 4px white
- Position: Overlapping cover (bottom-right area)

**Profile Info Section:**
- Background: Light lavender
- Padding: 24px horizontal, 80px top (for avatar overlap)

**Name:** 28px bold, black

**Address:** 16px regular, gray

**Bio:** 15px regular, black, line height 1.4

**Action Buttons:**
- Width: Half-width minus 8px gap
- Height: 56px
- Border radius: 12px
- Background: Light purple `Color(0xFFE8E4F3)`
- Icon: Dark purple, centered
- Layout: Row of 2 buttons (Email, DM)

**Tab Navigation:**
- Same style as message feed tabs
- Tabs: "Help categories" / "Groups"

**Category Cards:**
- Width: Half-width minus 8px gap
- Height: 80px
- Border radius: 12px
- Background: Light purple
- Title: 18px bold, left-aligned
- Add button: + icon, 32x32px, right-aligned

---

## Spacing System

```dart
// Padding/Margin values
extraSmall: 4px
small: 8px
medium: 12px
large: 16px
extraLarge: 24px
xxl: 32px
```

---

## Border Radius

```dart
small: 8px   // Buttons, small cards
medium: 12px // Most cards, inputs
large: 16px  // Large containers
circular: 50% // Avatars
```

---

## Icons

**Icon Pack:** Material Icons (default Flutter)

**Sizes:**
- Small: 20px (like counts)
- Medium: 24px (navigation, actions)
- Large: 32px (profile actions)

**Icons Used:**
- Search: `Icons.search`
- Filter: `Icons.filter_list` or `Icons.tune`
- Like: `Icons.thumb_up` or `Icons.favorite_border`
- Comment: `Icons.chat_bubble_outline`
- Menu: `Icons.more_vert`
- Email: `Icons.email_outlined`
- DM: `Icons.chat_bubble_outline`
- Add: `Icons.add`
- Back: `Icons.arrow_back_ios`

---

## Navigation Patterns

### Bottom Navigation (Future phases)
- 5 tabs: Feed, Groups, Reservations, Map, Profile
- Active: Primary color
- Inactive: Gray

### Deep Linking
- Message detail: `/message/:messageId`
- User profile: `/profile/:userId`
- Group: `/group/:groupId`

---

## Animations

**Standard Durations:**
- Quick: 150ms (micro-interactions)
- Normal: 300ms (screen transitions)
- Slow: 500ms (complex animations)

**Curves:**
- ease-in-out for most transitions
- spring for interactive elements

---

## Accessibility

**Touch Targets:**
- Minimum: 44x44px (iOS) / 48x48px (Android)
- Buttons: 48px height minimum

**Contrast Ratios:**
- Text on background: Minimum 4.5:1
- Large text: Minimum 3:1

---

## Responsive Breakpoints

**Phone:**
- Small: < 375px width
- Medium: 375-414px (standard)
- Large: > 414px (Plus/Max models)

**Tablet:**
- Portrait: 768px+
- Landscape: 1024px+

**Adjustments for Tablet:**
- Two-column layout for message feed
- Side panel for message detail
- Max content width: 800px

---

## Phase 1 Screens to Build

Based on designs and technical plan:

1. **Authentication**
   - Login screen
   - Register screen
   - Forgot password

2. **Message Feed** ✅ Designed
   - Tab navigation (All posts, Groups)
   - Message list
   - Search & filter

3. **Message Detail**
   - Full message view
   - Comments section
   - Like/comment actions

4. **User Profile** ✅ Designed
   - Profile view
   - Email/DM buttons
   - Groups/Help categories tabs

5. **Create Message**
   - Post creation modal/screen
   - Group selection
   - Image upload (optional)

---

## Implementation Priority

### High Priority (Week 1-2)
- [ ] Theme setup with color palette
- [ ] Message feed UI
- [ ] Message card component
- [ ] User profile UI

### Medium Priority (Week 3-4)
- [ ] Search functionality
- [ ] Filter modal
- [ ] Message detail screen
- [ ] Comment UI

### Low Priority (Week 5-6)
- [ ] Animations
- [ ] Tablet responsive layout
- [ ] Empty states
- [ ] Loading skeletons

---

## Notes

- **Simplified Tabs:** User wants "All Posts" and "Groups" (not Announcements)
- **Groups:** Will have nested filtering approach (to be designed)
- **Red Dot:** Likely unread indicator - confirm with user
- **Avatars in Likes:** Shows first 3 users who liked (social proof)

---

## Next Steps

1. Set up Flutter theme with these design tokens
2. Create reusable components (MessageCard, UserAvatar, etc.)
3. Build message feed screen
4. Build user profile screen
5. Connect to Firebase
6. Implement real-time messaging

---

**Reference Screenshots:**
- `screenshot-1.png` - Message feed with tabs and cards
- `screenshot-2.png` - User profile with cover photo and groups
