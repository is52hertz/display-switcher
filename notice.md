# Project handoff

- `DisplaySwitcher` is a Swift 6.2 / SwiftPM macOS 14 menu bar app with no
  third-party dependencies.
- DDC commands run through the fixed executable path
  `/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay` and may only
  write VCP `0x60` for the two allow-listed displays.
- Hardware-verified mappings:
  - MAG, BetterDisplay tag ID `295`: Mac `0x12`, Windows `0x0F`.
  - UHD, BetterDisplay tag ID `2`: Mac `0x0F`, Windows write `0x11`.
- RV200 remains absent from the macOS app because its Type-C DDC path is
  unreliable. The Windows companion uses Dxva2 over the physical DP path and
  allows only VCP `0x60`, with Mac `0x07` and Windows `0x08`.
- Windows identifies RV200 by the display device/EDID hardware ID `RVM2740`
  (verified Windows friendly name `RV200 Pro MAX`) and cross-checks readable
  VCP `0x60` replies against maximum `0x0E`. Physical index changed from 2 to
  1 across verified runs and is not used for selection; MAG and UHD reported
  maximum `0x03`.
- Hardware verification: RV200 read `current=0x08, max=0x0E` on current Windows
  DP, and switching Windows DP to Mac Type-C with `0x07` visibly succeeded in
  about 5 seconds. Post-switch DDC reads were unavailable.
- Non-current DP limitation: two Mac Type-C to Windows DP `0x08` attempts (one
  from the Codex execution environment and one from the normal user context)
  returned `SetVCPFeature` success but did not visibly switch the panel. Use
  the RV200 physical control to recover; do not treat API acceptance as a
  visible switch result. After physical recovery to Windows DP, reading VCP
  `0x60` again succeeded with `current=0x08, max=0x0E`.
- `Scripts/compile_and_run.sh` runs tests, creates an ad-hoc signed
  `DisplaySwitcher.app`, and launches it.
