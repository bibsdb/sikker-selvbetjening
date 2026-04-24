# Root Schema: group-vars.schema.json

## Overview

The root schema (`group-vars.schema.json`) defines the top-level structure for all group_vars overlay files. Each target library branch has a corresponding YAML file that conforms to this schema.

## Schema Reference

**File**: `schemas/group-vars.schema.json`

**Description**: Root schema for group_vars overlay files. Each top-level section is validated by its own dedicated schema file.

## Properties

### `printer` (optional)
**Type**: Object  
**Description**: Printer configuration section. Optional for targets that do not use a printer.

Defines all printer configurations including:
- Princh-integrated printers
- Printers with PPD files
- Printers without PPD files
- Default printer selection

See [Printer Configuration](printer.md) for detailed information.

### `wifi` (optional)
**Type**: Object  
**Description**: Wi-Fi configuration section. Optional for targets that do not define Wi-Fi settings.

Defines the wireless network settings including SSID, PSK, and hidden network flag.

See [Wi-Fi Configuration](wifi.md) for detailed information.

## Example

```yaml
printer:
  default_printer: konica_minolta_c258
  no_ppd:
    ricoh_c3010:
      display_name: "P11567 - Ricoh C3010"
      ip: 10.163.88.27
      protocol: ipp
    konica_minolta_c258:
      display_name: "KONICA MINOLTA C258"
      ip: 10.1.1.25
      protocol: ipp
  with_ppd:
    labelprinter:
      display_name: "Label printer"
      protocol: socket
      ip: 10.1.1.30
      ppd_file: assets/Ricoh-IM_C3010-PDF-Ricoh.ppd

wifi:
  ssid: GUEST
  psk: guest-secret
```

## Validation Rules

1. **Type enforcement**: All properties are strictly typed
2. **No additional properties**: The schema blocks any undefined properties to catch configuration errors early
3. **Cross-field constraints**: Additional validation ensures that `default_printer` references an actual printer ID (enforced by `scripts/validate-group-vars.py`)

## Section Schemas

The root schema delegates detailed validation to section-specific schemas:

- [Printer Configuration Schema](printer.md) - `schemas/sections/printer.schema.json`
- [Wi-Fi Configuration Schema](wifi.md) - `schemas/sections/wifi.schema.json`

## Related Files

- **Example configurations**: `group_vars/`
  - `group_vars/borgerservice.yml`
  - `group_vars/broager.yml`
  - `group_vars/nordborg.yml`

## See Also

- [About This Documentation](../about.md)
- [Printer Configuration](printer.md)
- [Wi-Fi Configuration](wifi.md)
