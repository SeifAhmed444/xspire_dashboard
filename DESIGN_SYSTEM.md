# XSpire Dashboard - Special Design System

## 🎨 Design Philosophy

This document outlines the comprehensive design system implemented for the XSpire Dashboard app.

## Color Palette

### Primary Colors

- **Primary Green**: `#1F5E3B`
  - Light variant: `#2E7D52`
  - Dark variant: `#154A2A`
  - Use case: Main buttons, app bar, primary actions

### Secondary Colors

- **Accent Orange/Gold**: `#F4A91F`
  - Light variant: `#FFC107`
  - Dark variant: `#D68A15`
  - Use case: Secondary actions, highlights, alerts

### Accent Colors

- **Cyan**: `#00BCD4` - Information, interactive elements
- **Green**: `#4CAF50` - Success states
- **Red**: `#E53935` - Errors and warnings
- **Orange**: `#FFA726` - Warnings

### Neutral Colors

- **White**: `#FFFFFF`
- **Light Grey**: `#F5F5F5` - Backgrounds
- **Grey**: `#9E9E9E` - Disabled states
- **Dark Grey**: `#424242` - Text

## Gradients

### Primary Gradient

```
Direction: Top-Left to Bottom-Right
Colors: #1F5E3B → #2E7D52
```

### Secondary Gradient

```
Direction: Top-Left to Bottom-Right
Colors: #F4A91F → #FFC107
```

### Sunset Gradient

```
Direction: Top-Left to Bottom-Right
Colors: #1F5E3B → #F4A91F
```

## Typography

### Display Large

- Size: 28pt
- Weight: 700 (Bold)
- Color: #1F5E3B
- Use case: Page titles

### Display Medium

- Size: 24pt
- Weight: 600 (Semi-Bold)
- Color: #1F5E3B
- Use case: Section headers

### Title Large

- Size: 20pt
- Weight: 600
- Color: #424242
- Use case: Card titles

### Body Large

- Size: 16pt
- Weight: 500
- Color: #424242
- Use case: Main text content

### Body Medium

- Size: 14pt
- Weight: 400
- Color: #616161
- Use case: Secondary text

### Label Small

- Size: 12pt
- Weight: 500
- Color: #9E9E9E
- Use case: Input labels, captions

## Components

### Buttons

#### Special Login Button

Features:

- Gradient background (Primary Green → Light Green)
- Rounded corners (16px)
- Shadow effects for depth
- Smooth scale animation on press
- Arrow icon with text
- Adaptive loading state with spinner

**Implementation Path**: `lib/core/widgets/special_login_button.dart`

#### Custom Button

- Flexible styling options
- Support for gradients
- Customizable colors and dimensions
- Shadow depth control

**Implementation Path**: `lib/core/widgets/custom_button.dart`

### Text Fields

#### Custom Text Form Field

Features:

- Focus-aware border color changes
- Prefix and suffix icons support
- Rounded corners (12px)
- Enhanced validation feedback
- Modern fill color (#F9FAFA)
- Icon color matches primary green (#1F5E3B)

**Implementation Path**: `lib/core/widgets/custom_text_field.dart`

### Cards & Containers

#### Card Theme

- Border radius: 12px
- Elevation: 2
- Background: White
- Shadow: Subtle, non-intrusive

#### Input Decoration

- Border radius: 12px
- Fill color: #F9FAFA
- Enabled border: #E0E0E0
- Focused border: #1F5E3B with 2px width
- Error border: #E53935

## Spacing System

Standard spacing unit: 8px

Common spacing values:

- `SizedBox(height: 8)` - Minimal spacing
- `SizedBox(height: 16)` - Small spacing
- `SizedBox(height: 24)` - Medium spacing
- `SizedBox(height: 32)` - Large spacing
- `SizedBox(height: 48)` - Extra large spacing

## Login Screen

The login screen features:

1. **Gradient Background**: Soft gradient with decorative circles
2. **Welcome Header**: Icon + title + subtitle
3. **Input Fields**: Email and password with icons
4. **Special Login Button**: Animated gradient button
5. **Decorative Elements**: Positioned circles for visual interest

### Recent Login Enhancements

- Visual hierarchy with header section
- Email validation with pattern matching
- Password validation with minimum length
- Loading state with spinner animation
- Smoothing transitions and interactions

## App Bar Theme

- Background: Primary Green (#1F5E3B)
- Text: White
- Elevation: 2
- Center-aligned titles
- Title size: 20pt, weight: 600

## Using the Design System

### Update Existing Components

When styling cards, buttons, or other elements:

```dart
// Use theme colors
style: TextStyle(
  color: Theme.of(context).colorScheme.primary,
)

// Use predefined gradients
decoration: BoxDecoration(
  gradient: AppColors.primaryGradient,
)

// Use consistent spacing
const SizedBox(height: 24),
```

### Create New Components

Follow these principles:

1. Use colors from `AppColors`
2. Apply consistent border radius (12-16px)
3. Include subtle shadows for elevation
4. Respect spacing guidelines
5. Support light theme as default

## References

- **Colors**: `lib/core/utils/app_colors.dart`
- **Theme**: `lib/main.dart` - `_buildAppTheme()` method
- **Components**: `lib/core/widgets/`

---

**Last Updated**: March 29, 2026
**Design Version**: 1.0
