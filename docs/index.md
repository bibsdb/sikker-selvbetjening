# Group Configuration (group_vars)

Groups can be used to create a policy configuration (GPO) for a collection of computers.

## How groups work

1. **Create a new file** in the `group_vars/` folder. The filename becomes the group's system name — it must not contain spaces or special characters, and must have the `.yml` extension.
2. **Add the settings** you want to apply to the group. This page provides detailed information about all supported configuration variables and usage examples.
3. **Commit the file.** An automatic validation process will run to check the file for syntax errors.
4. **Once validated**, a build process starts on GitHub where the settings are compiled into your images.
5. **The updated images are rolled out** to the computers, and the new settings take effect.

## Examples of use
For example, groups can be used to:

- Install a printer on all computers at a specific location
- Change the browser start page for computers at a specific location
- Customize power on/off schedules to the needs of a specific location

## Configuration Sections

### Printer Configuration
Comprehensive printer setup including support for:
- Multiple printer profiles (with and without PPD files)
- Princh-integrated printers
- Custom print settings and protocols

[Learn more about Printer Configuration →](schemas/printer.md)

### Wi-Fi Configuration
Wireless network settings including:
- SSID and pre-shared key (PSK)
- Hidden network support

[Learn more about Wi-Fi Configuration →](schemas/wifi.md)
