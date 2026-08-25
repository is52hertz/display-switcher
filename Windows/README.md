# Windows Companion

This dependency-free PowerShell CLI controls only the RV200 Pro MAX input
through Windows' built-in Dxva2 DDC/CI API. It never accepts an arbitrary VCP
code or value.

## Commands

Use the wrapper from the repository root:

```bat
Windows\DisplaySwitcher.Windows.cmd probe
Windows\DisplaySwitcher.Windows.cmd get-input
Windows\DisplaySwitcher.Windows.cmd switch windows
Windows\DisplaySwitcher.Windows.cmd switch mac
```

The wrapper starts Windows PowerShell with `-NoProfile`, `-NonInteractive`, and
a process-local `-ExecutionPolicy Bypass`; it does not change the machine or
user execution policy. The equivalent direct form is:

```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\Windows\DisplaySwitcher.Windows.ps1 -Action Probe
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\Windows\DisplaySwitcher.Windows.ps1 -Action GetInput
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\Windows\DisplaySwitcher.Windows.ps1 -Action Switch -Computer Windows
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\Windows\DisplaySwitcher.Windows.ps1 -Action Switch -Computer Mac
```

A successful DDC write returns exit code `0`. Invalid arguments, an ambiguous
or failed RV200 identity check, and Win32 API failures return a nonzero code.
`api=accepted` means Windows accepted the DDC write request; it does not prove
that the panel visibly changed inputs.

## Safety model

- The only writable VCP code is input source `0x60`.
- `Windows` is fixed to `0x08`; `Mac` is fixed to `0x07`.
- RV200 is first matched through its Windows display device/EDID hardware ID
  `RVM2740`. More than one match is treated as ambiguous.
- A readable input-source reply must report RV200's verified maximum `0x0E`.
- Physical enumeration index is never used for selection because it changed
  across verified runs. If the `RVM2740` device path is unavailable, the CLI
  fails without writing.
- When the stable hardware ID is unique, a switch may still be attempted if
  the preflight VCP read is unavailable only for `switch windows`; the stable
  identity remains mandatory. `switch mac` requires the readable `max=0x0E`
  cross-check. On the verified machine, two attempts to switch from Mac Type-C
  to Windows DP while DP was not current returned API success but did not
  visibly switch the panel. Treat this path as unavailable unless later
  hardware testing disproves that result.

`Probe` is read-only and queries only VCP `0x60`. Do not infer a visible input
change from the API result alone; the RV200 normally takes 4-5 seconds.

## Hardware verification

- With Windows DP current, RV200 reported `current=0x08` and `max=0x0E`.
- RV200 appeared as physical index 2 in an earlier run and index 1 in a later
  run, confirming that index is not a stable identity.
- Windows DP to Mac Type-C (`0x07`) visibly succeeded in about 5 seconds.
- The DDC read became unavailable after switching away from DP.
- Two Mac Type-C to Windows DP (`0x08`) attempts returned API success but did
  not visibly switch the panel. Recovery required the monitor's physical
  control, so non-current DP switching must not be treated as working. After
  physical recovery, the DDC read again returned `current=0x08, max=0x0E`.

## OpenSSH usage

The CLI does not install, enable, or configure OpenSSH Server. After OpenSSH is
separately configured, a Mac can invoke the wrapper with a fixed absolute path:

```bash
ssh <windows-host> 'cmd /c D:\WorkSpace\CodingSpace\SwitchScope\Windows\DisplaySwitcher.Windows.cmd switch windows'
ssh <windows-host> 'cmd /c D:\WorkSpace\CodingSpace\SwitchScope\Windows\DisplaySwitcher.Windows.cmd switch mac'
```

No SSH password, private key, or other credential is stored by this project.
On the verified Windows machine, no `sshd` service, OpenSSH server binary, or
port 22 listener was found. Checking the optional-feature installation state
required elevation and was deliberately not pursued.
