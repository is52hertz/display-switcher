# DisplaySwitcher

A personal macOS menu bar utility that switches two external displays between
hardware-verified Mac and Windows inputs through the installed BetterDisplay
CLI.

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
