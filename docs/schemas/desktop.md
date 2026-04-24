# Desktop Configuration Schema

## Overview

The desktop schema defines desktop customization settings for a group.

File: `schemas/sections/desktop.schema.json`

## Properties

### background_image (optional)
Type: string

Path to the desktop background image asset.

Constraints:
- Must start with `assets/`

Example:

```yaml
desktop:
  background_image: assets/bg-green.jpg
```

### shortcuts_in_menu (optional)
Type: array of strings

List of application shortcut IDs shown in the desktop menu.

Constraints:
- Must be a non-empty list when provided
- Each value must be a non-empty string

Example:

```yaml
desktop:
  shortcuts_in_menu:
    - firefox
    - libreoffice-writer
```

## Combined Example

```yaml
desktop:
  background_image: assets/bg-green.jpg
  shortcuts_in_menu:
    - firefox
    - libreoffice-writer
```

## Related

- [Root Schema](root.md)
- [Printer Configuration](printer.md)
- [WiFi Configuration](wifi.md)
