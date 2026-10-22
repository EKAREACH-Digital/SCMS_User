# Authentication Screen Testing Checklist

## Visual Elements Testing

### Hero Banner
- [ ] Green gradient displays smoothly with white overlay
- [ ] "Welcome Back" text shows on Login, "Create Account" on Sign Up
- [ ] Subtitle text updates correctly based on screen
- [ ] Canteen logo watermark visible at 15% opacity
- [ ] Shadow effect visible below the banner
- [ ] Border radius is 24px (not sharp corners)
- [ ] Text transitions smoothly when switching between screens

### Tab Switch
- [ ] "Log In" and "Sign Up" tabs are visible
- [ ] Selected tab background is green with white text
- [ ] Unselected tab is transparent with green text
- [ ] Border is soft gray (not harsh black)
- [ ] Shadow visible under the container
- [ ] Smooth animation when switching (320ms easeOutCubic)
- [ ] Font is bold and readable

### Input Fields
- [ ] Email field label says "Email Address" (not just "Email")
- [ ] Password field label says "Password"
- [ ] Confirm Password field label is correct on Sign Up
- [ ] Prefix icons are 20px and green
- [ ] Placeholder text is visible and readable
- [ ] Border color is soft gray (#E8E8E8) when not focused
- [ ] Border radius is 12px on all fields

### Input Focus States
- [ ] Tapping a field causes border to turn green
- [ ] A subtle shadow appears below focused field
- [ ] Fill color changes to light green tint
- [ ] Unfocusing reverses the animations smoothly
- [ ] Animation duration is smooth (300ms)
- [ ] Focus works on all three input fields
- [ ] Password visibility toggle icon changes smoothly

### Remember Me & Forgot Password
- [ ] "Remember me" checkbox displays on Login form only
- [ ] Checkbox is checkable/unchecable
- [ ] "Forgot Password?" link is interactive
- [ ] Forgot Password changes color on hover/tap (fades to lighter green)
- [ ] Both elements are only on Login form

### Buttons

#### Login/Sign Up Button
- [ ] "Log In" text on Login form
- [ ] "Sign Up" text on Sign Up form
- [ ] Green background with white bold text
- [ ] Shadow visible below button
- [ ] Tapping button causes scale animation (smooth shrink/grow)
- [ ] Button height is 52px
- [ ] Text is bold (w700) with letter spacing
- [ ] Border radius is 16px

#### Social Buttons
- [ ] Two buttons: "Google" and "Facebook"
- [ ] Icons display correctly inside circles
- [ ] Border radius is 12px (not pill-shaped)
- [ ] Border color is gray when normal
- [ ] Tapping button causes scale animation
- [ ] Border color changes to green-tinted on press
- [ ] Both buttons have subtle shadow
- [ ] Same on both Login and Sign Up screens

### Form Layout Consistency

#### Login Form
```
1. Email field (20px spacing)
2. Password field (20px spacing)
3. Remember me + Forgot Password (16px spacing)
4. Log In button (20px spacing)
5. Divider "OR CONTINUE WITH" (20px spacing)
6. Social buttons (Google + Facebook)
```

#### Sign Up Form
```
1. Email field (20px spacing)
2. Password field (20px spacing)
3. Confirm Password field (20px spacing)
4. Sign Up button (20px spacing)
5. Divider "OR CONTINUE WITH" (20px spacing)
6. Social buttons (Google + Facebook)
```

- [ ] All spacing is consistent at 20px
- [ ] Left/right padding is 16px from screen edge
- [ ] Elements are vertically aligned
- [ ] No overlap or misalignment

---

## Animation Testing

### Form Transition (Login ↔ Sign Up)
- [ ] Click "Sign Up" tab - form slides from right to left, fades in, scales up
- [ ] Click "Log In" tab - form slides from left to right, fades in, scales up
- [ ] Animation is smooth (500ms total)
- [ ] No jarring or stuttering
- [ ] Previous form slides out while new form slides in
- [ ] Text fields appear in correct order

### Hero Text Animation
- [ ] Title text fades, scales, and slides smoothly when switching
- [ ] Subtitle text follows same animations with slight delay
- [ ] Text animations are smooth (400ms)
- [ ] No flickering or instant changes
- [ ] Both texts update without overlap

### Button Press Animations
- [ ] Tap any button - it scales down slightly then back to normal
- [ ] Animation is quick (150ms total)
- [ ] Provides satisfying tactile feedback
- [ ] Works on Login, Sign Up, and Social buttons

### Input Focus Animations
- [ ] Tap an input field - border smoothly turns green
- [ ] Shadow appears gradually below field
- [ ] Fill color changes to light green tint
- [ ] All animations are synchronized
- [ ] Duration is smooth (300ms)
- [ ] Works on all three input fields

### Tab Switch Animation
- [ ] Click "Log In" or "Sign Up" - selected tab background animates
- [ ] Text color changes smoothly (white when selected, green when not)
- [ ] Unselected tab fades to transparent
- [ ] Animation is smooth (320ms)
- [ ] No color clipping or sharp transitions

### Password Visibility Toggle
- [ ] Icon changes smoothly when toggling visibility
- [ ] Password text toggles between dots and visible text
- [ ] Animation feels responsive
- [ ] Works on both Password fields

---

## Device & Orientation Testing

### Portrait Mode
- [ ] All elements fit within screen without scrolling (on normal devices)
- [ ] Text is readable
- [ ] Buttons are easily tappable
- [ ] Shadows don't clip at edges
- [ ] Banner gradient is visible

### Landscape Mode
- [ ] Layout adjusts properly
- [ ] All elements remain aligned
- [ ] Form fields don't overflow
- [ ] Button sizes remain touch-friendly

### Different Screen Sizes
- [ ] Test on small phones (360px width)
- [ ] Test on large phones (600px width)
- [ ] Test on tablets (1200px width)
- [ ] Spacing scales appropriately

---

## Interaction Testing

### Keyboard Behavior
- [ ] Tapping email field opens keyboard
- [ ] Tapping password field opens keyboard with password input type
- [ ] Tab order is correct: Email → Password → Confirm Password (on signup)
- [ ] "Forgot Password?" doesn't trigger keyboard

### Focus Management
- [ ] Focus flows logically through fields
- [ ] Keyboard dismiss works properly
- [ ] Previous focus isn't lost when switching tabs

### Responsiveness
- [ ] All animations play without lag
- [ ] No dropped frames or jank
- [ ] Smooth 60fps animations
- [ ] Performance is consistent

---

## Edge Cases

### Rapid Tab Switching
- [ ] Rapidly click between Login and Sign Up
- [ ] Animations don't queue up or stutter
- [ ] Latest form displays correctly

### Long Input Text
- [ ] Long email addresses fit in field
- [ ] Long passwords display correctly (as dots)
- [ ] Text doesn't overflow button labels

### Keyboard Open/Close
- [ ] When keyboard opens, form doesn't shift unexpectedly
- [ ] When keyboard closes, form returns to original position
- [ ] Animations still work smoothly

### Multiple Rapid Button Taps
- [ ] Rapidly tap buttons
- [ ] Scale animations don't queue up
- [ ] Only one animation plays at a time

---

## Cross-Platform Testing

### Android
- [ ] Material Design principles followed
- [ ] Touch feedback is responsive
- [ ] Animations are smooth
- [ ] Shadows render correctly

### iOS
- [ ] iOS aesthetics maintained
- [ ] Cupertino-style feedback (if applicable)
- [ ] Smooth animations at 60fps
- [ ] Safe area respected

### Web
- [ ] Animations work in browser
- [ ] Mouse hover effects work
- [ ] Touch events work on mobile browsers
- [ ] No performance issues

---

## Performance Metrics

### Animation Smoothness
- [ ] 60fps target maintained
- [ ] No dropped frames during form transitions
- [ ] Button presses respond instantly
- [ ] Focus animations are smooth

### Memory Usage
- [ ] No memory leaks after switching forms multiple times
- [ ] Animation controllers properly disposed
- [ ] No accumulating memory usage

### Build Time
- [ ] App builds successfully
- [ ] No compilation warnings
- [ ] Analyze reports no issues

---

## Final Verification Checklist

- [ ] All animations use proper easing curves
- [ ] Color palette matches green (#23C452) consistently
- [ ] Typography hierarchy is clear (font weights 400-800)
- [ ] Spacing is consistent (20px primary, 16px secondary)
- [ ] Shadows have appropriate blur and opacity
- [ ] Border radius values are: 24px (banner), 12px (fields/social), 16px (primary button), 10px (tab item)
- [ ] Touch targets are minimum 48px height
- [ ] All micro-interactions are present and smooth
- [ ] No deprecation warnings in flutter analyze
- [ ] Code is properly formatted with dart format
- [ ] Both screens have identical structure and spacing
- [ ] Transitions are smooth and natural

---

## Sign-Off

When all checkboxes are marked, the authentication screens are ready for deployment!

| Item | Status | Date | Notes |
|------|--------|------|-------|
| Visual Testing | ⬜ | | |
| Animation Testing | ⬜ | | |
| Device Testing | ⬜ | | |
| Performance Testing | ⬜ | | |
| Cross-Platform Testing | ⬜ | | |
| **Final Approval** | ⬜ | | |

