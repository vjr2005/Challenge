# Deep Linking

The app supports URL-based deep links with the `challenge://` scheme.

## Available Routes

| URL | Destination |
|-----|-------------|
| `challenge://home` | Home screen |
| `challenge://character/list` | Character list |
| `challenge://character/detail/{id}` | Character detail |
| `challenge://episode/character/{id}` | Character episodes |

## Testing from Terminal

### Simulator

Use `xcrun simctl openurl` to test deep links on the iOS Simulator:

```bash
# Open home screen
xcrun simctl openurl booted "challenge://home"

# Open character list
xcrun simctl openurl booted "challenge://character/list"

# Open character detail (e.g., Rick Sanchez with id 1)
xcrun simctl openurl booted "challenge://character/detail/1"

# Open character episodes (e.g., Rick Sanchez episodes with character id 1)
xcrun simctl openurl booted "challenge://episode/character/1"
```

> **Note:** The `booted` parameter targets the currently running simulator. You can also specify a device UDID.

### Physical Device

Use `xcrun devicectl` to test deep links on a physical device (requires Xcode 15+):

```bash
# List connected devices
xcrun devicectl list devices

# Open deep link on device
xcrun devicectl device process launch --device <DEVICE_UDID> --url "challenge://character/detail/1"
```

Alternatively, you can use Safari on the device and navigate to the deep link URL directly.
