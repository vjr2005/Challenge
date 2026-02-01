# Deep Linking

The app supports URL-based deep links with the `challenge://` scheme.

## Available Routes

| URL | Destination |
|-----|-------------|
| `challenge://home` | Home screen |
| `challenge://characters` | Character list |
| `challenge://characters/{id}` | Character detail |

## Testing from Terminal

### Simulator

Use `xcrun simctl openurl` to test deep links on the iOS Simulator:

```bash
# Open home screen
xcrun simctl openurl booted "challenge://home"

# Open character list
xcrun simctl openurl booted "challenge://characters"

# Open character detail (e.g., Rick Sanchez with id 1)
xcrun simctl openurl booted "challenge://characters/1"
```

> **Note:** The `booted` parameter targets the currently running simulator. You can also specify a device UDID.

### Physical Device

Use `xcrun devicectl` to test deep links on a physical device (requires Xcode 15+):

```bash
# List connected devices
xcrun devicectl list devices

# Open deep link on device
xcrun devicectl device process launch --device <DEVICE_UDID> --url "challenge://characters/1"
```

Alternatively, you can use Safari on the device and navigate to the deep link URL directly.
