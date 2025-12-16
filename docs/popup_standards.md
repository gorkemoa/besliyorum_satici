# Pop-up Standards

All pop-ups in the application must use the `AppDialog` component to ensure consistency.

## Component: `AppDialog`

Located at: `lib/core/components/app_dialog.dart`

### Usage

```dart
AppDialog.show(
  context: context,
  title: 'Header Title',
  content: 'Message body text.',
  type: AppDialogType.confirmation, // or .info, .alert
  onConfirm: () {
    // Handle confirmation
  },
);
```

### Dialog Types

#### 1. Confirmation (`AppDialogType.confirmation`)
Used for actions requiring user decision (e.g., Delete, Logout, Confirm Order).
- **Buttons**: "Vazgeç" (Red) and "Onayla" (Green).
- **Behavior**: Two distinct choices.

#### 2. Info / Alert (`AppDialogType.info` / `AppDialogType.alert`)
Used for feedback messages (e.g., Success, Error, Info).
- **Buttons**: "Tamam" (Green).
- **Behavior**: Single acknowledgement button.

## Visual Design

- **Border Radius**: 20px
- **Border**: Thin Grey
- **Title**: Dark Red, Bold, 18px
- **Close Icon**: Top right, Dark Red
- **Content**: Dark Red, 14px, Centered
- **Buttons**: Rounded (5px radius), Full Width (or Expanded)
