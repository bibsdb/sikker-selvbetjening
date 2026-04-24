# Printer Configuration Schema

## Overview

The printer schema (`printer.schema.json`) defines all valid printer configurations for library branches. It supports multiple types of printers with flexible configuration options.

**File**: `schemas/sections/printer.schema.json`

**Description**: Schema for the printer section used in group_vars overlay files. Supports the newer nested model and a legacy flat model during migration.

## Printer Types

### Princh Printers
Printers integrated with the Princh printing system.

**Properties**:
- `display_name` (string, required): Human-readable printer name
- `id` (string, required): Princh identifier for the printer

### Printers Without PPD Files (no_ppd)
Standard network printers that don't require a PPD (PostScript Printer Description) file.

**Properties**:
- `display_name` (string, required): Human-readable printer name
- `ip` (string, required): IP address of the printer
- `protocol` (string, optional): Transport protocol (e.g., "ipp", "socket", "lpd")
- `description` (string, optional): Additional printer description
- `settings` (object, optional): Print settings
  - `page_size` (string): Paper size (e.g., "A4", "Letter")
  - `color_mode` (string): Color mode (e.g., "rgb", "bw", "cmyk")
  - `duplex` (string): Duplex mode (e.g., "none", "duplex", "duplex_tumble")
  - `orientation` (string): Page orientation (e.g., "portrait", "landscape")

### Printers With PPD Files (with_ppd)
Specialized printers that require a PPD file for proper configuration.

**Properties** (same as no_ppd, plus):
- `ppd_file` (string, required): Path to the PPD file (must start with "assets/")

## Schema Structure

```
printer:
  default_printer: (string) - Logical ID of the default printer
  princh:
    [printer_id]:               # Keyed by logical ID
      display_name: (string)
      id: (string)
  no_ppd:
    [printer_id]:               # Keyed by logical ID
      display_name: (string)
      ip: (string)
      protocol: (string, optional)
      description: (string, optional)
      settings: (object, optional)
  with_ppd:
    [printer_id]:               # Keyed by logical ID
      display_name: (string)
      ip: (string)
      protocol: (string, optional)
      description: (string, optional)
      settings: (object, optional)
      ppd_file: (string)
```

## Naming Conventions

All printer IDs (keys) must follow these naming rules:

- Start with a lowercase letter
- Contain only lowercase letters, numbers, underscores, or hyphens
- Pattern: `^[a-z][a-z0-9_-]*$`

**Examples**: `ricoh_c3010`, `konica-minolta-c258`, `labelprinter`, `xerox101`

## Examples

### Basic Configuration

```yaml
printer:
  default_printer: ricoh_c3010
  no_ppd:
    ricoh_c3010:
      display_name: "Ricoh C3010"
      ip: 10.163.88.27
      protocol: ipp
```

### With Multiple Printers

```yaml
printer:
  default_printer: konica_minolta_c258
  no_ppd:
    ricoh_c3010:
      display_name: "P11567 - Ricoh C3010"
      ip: 10.163.88.27
      protocol: ipp
      settings:
        page_size: A4
        color_mode: rgb
        duplex: none
        orientation: portrait
    konica_minolta_c258:
      display_name: "KONICA MINOLTA C258"
      ip: 10.1.1.25
      protocol: ipp
      settings:
        page_size: A4
        color_mode: rgb
        duplex: duplex_tumble
        orientation: landscape
```

### With PPD Files

```yaml
printer:
  default_printer: labelprinter
  with_ppd:
    labelprinter:
      display_name: "Label printer"
      protocol: socket
      ip: 10.1.1.30
      ppd_file: assets/Ricoh-IM_C3010-PDF-Ricoh.ppd
```

### With Princh Integration

```yaml
printer:
  default_printer: xerox_101
  princh:
    xerox-101:
      display_name: "Printer in makerspace"
      id: 854658
  no_ppd:
    xerox_101:
      display_name: "Xerox (Standard)"
      ip: 10.1.1.50
      protocol: ipp
```

## Validation Rules

1. **Unique printer IDs**: Each printer must have a unique logical ID
2. **Default printer membership**: The `default_printer` must match an ID in either `no_ppd` or `with_ppd`
   - This constraint is enforced by `scripts/validate-group-vars.py`
3. **Valid naming**: All printer IDs must follow the lowercase pattern
4. **PPD file paths**: PPD files must be located in the `assets/` directory
5. **Required fields**: Each printer profile must include `display_name` and `ip`

## Related Files

- **Validator**: `scripts/validate-group-vars.py`
- **Example configurations**: `group_vars/`
- **Root schema**: [Group Vars Root Schema](root.md)
- **Section schemas**: [Wi-Fi Configuration](wifi.md)

## See Also

- [Root Schema: group-vars.schema.json](root.md)
- [Wi-Fi Configuration Schema](wifi.md)
- [About This Documentation](../about.md)
