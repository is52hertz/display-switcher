# DisplaySwitcher

A personal display-input switcher for one known three-monitor Mac and Windows
desk. The macOS menu bar app controls MAG and UHD through BetterDisplay, while
the dependency-free Windows companion controls RV200 through Dxva2 DDC/CI.

## Requirements

- macOS 14 or later
- BetterDisplay installed at `/Applications/BetterDisplay.app`
- BetterDisplay running with CLI integration enabled

## Supported displays

| Display | Mac input | Windows input |
| --- | --- | --- |
| MAG 274QR E20 | HDMI 2 (`0x12`) | DisplayPort 1 (`0x0F`) |
| UHD HDR | DisplayPort 1 (`0x0F`) | HDMI 1 write (`0x11`) |

RV200 Pro MAX is intentionally excluded because its Type-C DDC path is not
reliable on macOS.

## Build and run

```bash
swift test
Scripts/compile_and_run.sh
```

The packaged menu bar app is created at `DisplaySwitcher.app`.

## Windows companion

The Windows CLI can read and switch only RV200 input source VCP `0x60`. Its
fixed mappings are Windows DP `0x08` and Mac Type-C `0x07`; arbitrary VCP codes
and values are not accepted.

```bat
Windows\DisplaySwitcher.Windows.cmd probe
Windows\DisplaySwitcher.Windows.cmd get-input
Windows\DisplaySwitcher.Windows.cmd switch windows
Windows\DisplaySwitcher.Windows.cmd switch mac
```

See [`Windows/README.md`](Windows/README.md) for identity checks, exit-code
behavior, hardware limitations, and OpenSSH invocation examples. The verified
RV200 did not switch from Mac Type-C back to Windows when DP was not current,
even though Windows accepted the DDC write request. Windows DP to Mac Type-C
did visibly succeed in about 5 seconds.
