# Project handoff

- `DisplaySwitcher` is a Swift 6.2 / SwiftPM macOS 14 menu bar app with no
  third-party dependencies.
- DDC commands run through the fixed executable path
  `/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay` and may only
  write VCP `0x60` for the two allow-listed displays.
- Hardware-verified mappings:
  - MAG, BetterDisplay tag ID `295`: Mac `0x12`, Windows `0x0F`.
  - UHD, BetterDisplay tag ID `2`: Mac `0x0F`, Windows write `0x11`.
- RV200 is deliberately absent from the macOS app. Its Type-C DDC path is
  unreliable; the future Windows companion should use the stable physical DP
  path and the observed private values Mac `7` / Windows `8`.
- `Scripts/compile_and_run.sh` runs tests, creates an ad-hoc signed
  `DisplaySwitcher.app`, and launches it.
