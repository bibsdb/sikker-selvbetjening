# Wi-Fi Configuration Schema

## Overview

The Wi-Fi schema (`wifi.schema.json`) defines wireless network configuration for library branches.

**File**: `schemas/sections/wifi.schema.json`

**Description**: Schema for the Wi-Fi section used in group_vars overlay files.

## Schema Properties

### `ssid` (required)
**Type**: String  
**Description**: SSID of the wireless network the client should connect to.  
**Constraints**: 
- Minimum length: 1 character
- Cannot be empty

### `psk` (required)
**Type**: String  
**Description**: Pre-shared key (password) for the wireless network.  
**Constraints**:
- Minimum length: 1 character
- Cannot be empty
- ⚠️ **Security Note**: This is sensitive data. In production systems, consider replacing with runtime secret references instead of keeping credentials in version control.

### `hidden` (optional)
**Type**: Boolean  
**Description**: Whether the SSID is hidden and requires active probing by the client.  
**Default**: Not set (network is assumed to broadcast SSID)

## Schema Structure

```yaml
wifi:
  ssid: (string, required)    # Network name
  psk: (string, required)     # Network password
  hidden: (boolean, optional) # Whether SSID is hidden
```

## Examples

### Standard Configuration

```yaml
wifi:
  ssid: GUEST
  psk: guest-secret
```

### Hidden Network

```yaml
wifi:
  ssid: PRIVATE
  psk: private-secret
  hidden: true
```

### Full Example with Multiple Words

```yaml
wifi:
  ssid: "Library Guest Network"
  psk: "SeC@reP@ssw0rd123"
  hidden: false
```

## Validation Rules

1. **Required fields**: Both `ssid` and `psk` must be provided
2. **Non-empty strings**: Neither field can be an empty string
3. **No additional properties**: Only the three defined properties are allowed
4. **Boolean for hidden**: The `hidden` field only accepts `true` or `false`

## Security Considerations

The `psk` field contains sensitive credential data. Best practices:

- ✅ **Current approach**: Secure the repository using GitHub access controls
- 🔄 **Future improvement**: Replace with runtime secret references
- 🔐 **Alternative**: Use WPA Enterprise (802.1X) with certificate-based authentication

## YAML Representation

### True/False Values

When `hidden` is set to `true` or `false` in the YAML source, they are rendered as lowercase `true`/`false` in configuration files:

```yaml
# Source (group_vars YAML)
wifi:
  hidden: true

# Rendered (config file)
wifi.hidden=true
```

## Related Files

- **Example configurations**: `group_vars/`
  - `group_vars/borgerservice.yml`
  - `group_vars/broager.yml`
  - `group_vars/nordborg.yml`

- **Root schema**: [Group Vars Root Schema](root.md)
- **Printer schema**: [Printer Configuration Schema](printer.md)

## See Also

- [Root Schema: group-vars.schema.json](root.md)
- [Printer Configuration Schema](printer.md)
- [About This Documentation](../about.md)
