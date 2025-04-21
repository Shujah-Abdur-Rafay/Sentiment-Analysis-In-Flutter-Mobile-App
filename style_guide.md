# Elegant Design System Style Guide

## Overview

This style guide outlines the elegant and professional design system implemented across the application. The design focuses on clean layouts, subtle shadows, and a sophisticated color palette to create a polished, business-oriented aesthetic.

## Color Palette

### Primary Colors

- **Primary (Deep Indigo)**: `#3E4784`
- **Secondary (Slate Blue)**: `#6A7B90`
- **Tertiary (Sage Green)**: `#78A083`

### Background Colors

- **Background (Off-white)**: `#F8F9FC`
- **Background Alt (Light Gray-blue)**: `#ECEFF5`
- **Surface (White)**: `#FFFFFF`
- **Surface Light (Very Light Gray)**: `#F5F6FA`
- **Surface Dark (Medium Light Gray)**: `#E1E5EE`

### Text Colors

- **Text Primary (Dark Gray)**: `#2E3441`
- **Text Secondary (Medium Gray)**: `#6D7A8C`
- **Text Hint (Light Gray)**: `#ADB5BD`
- **Text Highlight (Accent Blue)**: `#4E5BA6`

### State Colors

- **Success (Green)**: `#4CAF50`
- **Warning (Amber)**: `#FFA000`
- **Error (Red)**: `#E53935`
- **Info (Blue)**: `#2196F3`
- **Accent (Dusty Blue)**: `#8E9CB9`

### Gradients

- **Primary Gradient**: `#3E4784` to `#4E5BA6`
- **Blue Gradient**: `#4E5BA6` to `#8E9CB9`
- **Green Gradient**: `#78A083` to `#9EBAA5`
- **Neutral Gradient**: `#ECEFF5` to `#F8F9FC`
- **Elegant Gradient**: `#ECEFF5` to `#F8F9FC` to `#FFFFFF`

## Typography

### Font Family

- Primary Font: System default or Roboto
- Headers and titles may use slightly heavier weights for emphasis

### Text Styles

- **Headings**: Use dark gray (#2E3441) with medium to bold weight
- **Body Text**: Use medium gray (#6D7A8C) with regular weight
- **Captions/Hints**: Use light gray (#ADB5BD)
- **Highlights/Accents**: Use accent blue (#4E5BA6) or primary color

### Sizing

- **Large Titles**: 24px
- **Headings**: 18-20px
- **Subheadings**: 16px
- **Body**: 14-16px
- **Small/Caption**: 12px

## Components

### Buttons

#### Standard Button (CustomElevatedButton)

- Height: 48px
- Border Radius: 8px
- Normal State: Solid fill with primary color
- Text: White with 16px font size
- Shadow: Subtle (2px y-offset, 4px blur, 0.2 opacity)
- Hover/Pressed: Slight scale transform (0.98)

#### Outlined Button

- Same dimensions as standard button
- 1.5px border with primary color
- Text in primary color
- No shadow
- Transparent background

### Text Fields (FuturisticTextField)

- Clean, rectangular design with 8px border radius
- 1px border in light gray
- Label above the field in secondary text color
- Animated underline on focus
- Subtle hover/focus states

### Cards (ProfessionalCard)

- White background
- 1px border in light gray
- 12px border radius
- Subtle shadow (2px y-offset, 6px blur, 0.08 opacity)
- Clean internal padding (16px)

### Toggle Switch (\_ProfessionalToggle)

- Height: 24px
- Width: 46px
- Circular thumb
- Clean transition animation
- Active state uses primary color
- Inactive state uses light surface color

### Option Items (ProfessionalOption)

- Clean rectangular layout with 8px border radius
- Icon square with light background
- Clear typography hierarchy
- Subtle borders and shadows

## Layout Guidelines

### Spacing

- **Extra Small**: 4px
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **Extra Large**: 32px+

### Containers

- Use consistent padding (16px recommended)
- Maintain reasonable margins between elements (16-24px)
- Group related elements with consistent spacing

### Shadows

- **Light Mode**: `color: rgba(0,0,0,0.08), y-offset: 2px, blur: 6px, spread: 0`
- **Dark Mode**: `color: rgba(0,0,0,0.2), y-offset: 2px, blur: 8px, spread: 0`

## Animations

### Principles

- Use subtle, purposeful animations
- Keep durations short (150-300ms for micro-interactions)
- Use appropriate easing curves (easeOutQuart for most transitions)
- Avoid flashy or distracting effects

### Common Animations

- Button press: Scale to 0.98
- Focus transitions: 300ms
- Page transitions: 400ms

## Best Practices

1. **Consistency**: Maintain consistent spacing, typography, and color usage
2. **Hierarchy**: Create clear visual hierarchy using size, weight, and color
3. **Whitespace**: Embrace whitespace to create clean, readable layouts
4. **Feedback**: Provide subtle visual feedback for interactive elements
5. **Accessibility**: Maintain sufficient contrast ratios and touch target sizes

## Theme Switching

The application supports both light and dark modes with appropriate color adjustments:

- **Light Mode**: Primarily uses white backgrounds with dark text
- **Dark Mode**: Uses deeper background colors with lighter text
- Components automatically adjust their styling based on the current theme
