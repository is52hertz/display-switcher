param(
    [string]$Action = "Probe",
    [string]$Computer
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not ("DisplaySwitcherWindows" -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Threading;

public static class DisplaySwitcherWindows
{
    private const byte InputSourceVcpCode = 0x60;
    private const uint WindowsInput = 0x08;
    private const uint MacInput = 0x07;
    private const uint Rv200MaximumInput = 0x0E;
    private const string Rv200HardwareId = "RVM2740";

    [StructLayout(LayoutKind.Sequential)]
    private struct RECT
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct MONITORINFOEX
    {
        public int cbSize;
        public RECT rcMonitor;
        public RECT rcWork;
        public uint dwFlags;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string szDevice;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct DISPLAY_DEVICE
    {
        public int cb;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string DeviceName;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string DeviceString;

        public uint StateFlags;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string DeviceID;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string DeviceKey;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct PHYSICAL_MONITOR
    {
        public IntPtr hPhysicalMonitor;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string szPhysicalMonitorDescription;
    }

    private enum MC_VCP_CODE_TYPE
    {
        Momentary = 0,
        SetParameter = 1
    }

    private delegate bool MonitorEnumProc(
        IntPtr hMonitor,
        IntPtr hdcMonitor,
        ref RECT monitorRect,
        IntPtr userData
    );

    private sealed class MonitorRecord
    {
        public int Index;
        public IntPtr Handle;
        public string Description;
        public string DisplayDevice;
        public string DeviceId;
        public string DeviceKey;
    }

    private sealed class MonitorCollection : IDisposable
    {
        public readonly List<MonitorRecord> Monitors = new List<MonitorRecord>();
        private readonly List<PHYSICAL_MONITOR[]> physicalMonitorGroups =
            new List<PHYSICAL_MONITOR[]>();

        public void AddGroup(PHYSICAL_MONITOR[] group)
        {
            physicalMonitorGroups.Add(group);
        }

        public void Dispose()
        {
            foreach (PHYSICAL_MONITOR[] group in physicalMonitorGroups)
            {
                DestroyPhysicalMonitors((uint)group.Length, group);
            }
        }
    }

    private sealed class VcpRead
    {
        public bool Ok;
        public uint Current;
        public uint Maximum;
        public int Error;
    }

    private sealed class Target
    {
        public MonitorRecord Monitor;
        public string Identity;
        public VcpRead Preflight;
    }

    [DllImport("user32.dll")]
    private static extern bool EnumDisplayMonitors(
        IntPtr hdc,
        IntPtr clipRect,
        MonitorEnumProc callback,
        IntPtr userData
    );

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern bool GetMonitorInfo(
        IntPtr hMonitor,
        ref MONITORINFOEX monitorInfo
    );

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern bool EnumDisplayDevices(
        string device,
        uint deviceNumber,
        ref DISPLAY_DEVICE displayDevice,
        uint flags
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool GetNumberOfPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        out uint count
    );

    [DllImport("dxva2.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    private static extern bool GetPhysicalMonitorsFromHMONITOR(
        IntPtr hMonitor,
        uint count,
        [Out] PHYSICAL_MONITOR[] monitors
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool DestroyPhysicalMonitors(
        uint count,
        PHYSICAL_MONITOR[] monitors
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool GetVCPFeatureAndVCPFeatureReply(
        IntPtr physicalMonitor,
        byte vcpCode,
        out MC_VCP_CODE_TYPE codeType,
        out uint currentValue,
        out uint maximumValue
    );

    [DllImport("dxva2.dll", SetLastError = true)]
    private static extern bool SetVCPFeature(
        IntPtr physicalMonitor,
        byte vcpCode,
        uint value
    );

    private static MonitorCollection EnumerateMonitors()
    {
        MonitorCollection result = new MonitorCollection();
        int physicalIndex = 0;

        bool enumResult = EnumDisplayMonitors(
            IntPtr.Zero,
            IntPtr.Zero,
            delegate (IntPtr hMonitor, IntPtr hdc, ref RECT rect, IntPtr data)
            {
                MONITORINFOEX monitorInfo = new MONITORINFOEX();
                monitorInfo.cbSize = Marshal.SizeOf(typeof(MONITORINFOEX));
                string displayDevice = "";
                string deviceId = "";
                string deviceKey = "";

                if (GetMonitorInfo(hMonitor, ref monitorInfo))
                {
                    displayDevice = monitorInfo.szDevice ?? "";
                    DISPLAY_DEVICE monitorDevice = new DISPLAY_DEVICE();
                    monitorDevice.cb = Marshal.SizeOf(typeof(DISPLAY_DEVICE));

                    if (EnumDisplayDevices(displayDevice, 0, ref monitorDevice, 1))
                    {
                        deviceId = monitorDevice.DeviceID ?? "";
                        deviceKey = monitorDevice.DeviceKey ?? "";
                    }
                }

                uint count;
                if (!GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor, out count))
                {
                    return true;
                }

                PHYSICAL_MONITOR[] physicalMonitors = new PHYSICAL_MONITOR[count];
                if (!GetPhysicalMonitorsFromHMONITOR(hMonitor, count, physicalMonitors))
                {
                    return true;
                }

                result.AddGroup(physicalMonitors);
                foreach (PHYSICAL_MONITOR physicalMonitor in physicalMonitors)
                {
                    result.Monitors.Add(new MonitorRecord {
                        Index = physicalIndex++,
                        Handle = physicalMonitor.hPhysicalMonitor,
                        Description = physicalMonitor.szPhysicalMonitorDescription ?? "",
                        DisplayDevice = displayDevice,
                        DeviceId = deviceId,
                        DeviceKey = deviceKey
                    });
                }

                return true;
            },
            IntPtr.Zero
        );

        if (!enumResult)
        {
            result.Dispose();
            throw new Win32Exception(Marshal.GetLastWin32Error());
        }

        return result;
    }

    private static VcpRead ReadInput(MonitorRecord monitor, int attempts)
    {
        VcpRead result = new VcpRead();

        for (int attempt = 0; attempt < attempts; attempt++)
        {
            MC_VCP_CODE_TYPE type;
            uint current;
            uint maximum;
            bool ok = GetVCPFeatureAndVCPFeatureReply(
                monitor.Handle,
                InputSourceVcpCode,
                out type,
                out current,
                out maximum
            );

            result.Ok = ok;
            result.Current = current;
            result.Maximum = maximum;
            result.Error = ok ? 0 : Marshal.GetLastWin32Error();

            if (ok)
            {
                return result;
            }

            if (attempt + 1 < attempts)
            {
                Thread.Sleep(300);
            }
        }

        return result;
    }

    private static bool HasRv200HardwareId(MonitorRecord monitor)
    {
        return monitor.DeviceId.StartsWith(
            @"\\?\DISPLAY#" + Rv200HardwareId + "#",
            StringComparison.OrdinalIgnoreCase
        );
    }

    private static Target ResolveTarget(MonitorCollection collection, bool requireReadable)
    {
        List<MonitorRecord> hardwareMatches = collection.Monitors.FindAll(
            delegate (MonitorRecord monitor) { return HasRv200HardwareId(monitor); }
        );

        if (hardwareMatches.Count > 1)
        {
            throw new InvalidOperationException(
                "RV200 hardware ID is not unique; refusing to select a monitor."
            );
        }

        if (hardwareMatches.Count == 1)
        {
            VcpRead preflight = ReadInput(hardwareMatches[0], 10);
            if (preflight.Ok && preflight.Maximum != Rv200MaximumInput)
            {
                throw new InvalidOperationException(
                    "RV200 hardware ID matched but VCP 0x60 maximum was not 0x0E."
                );
            }

            if (requireReadable && !preflight.Ok)
            {
                throw new InvalidOperationException(
                    "RV200 was identified, but VCP 0x60 could not be read (error=" +
                    preflight.Error + ")."
                );
            }

            return new Target {
                Monitor = hardwareMatches[0],
                Identity = "hardware-id:" + Rv200HardwareId,
                Preflight = preflight
            };
        }

        throw new InvalidOperationException(
            "RV200 hardware ID was not found; refusing to select a monitor."
        );
    }

    private static string FormatDeviceId(string value)
    {
        return String.IsNullOrEmpty(value) ? "unavailable" : value;
    }

    public static void Probe()
    {
        using (MonitorCollection collection = EnumerateMonitors())
        {
            foreach (MonitorRecord monitor in collection.Monitors)
            {
                VcpRead read = ReadInput(monitor, 3);
                Console.WriteLine(
                    "index={0} display={1} deviceId={2} vcp60={3} current={4} max={5} error={6}",
                    monitor.Index,
                    String.IsNullOrEmpty(monitor.DisplayDevice) ? "unavailable" : monitor.DisplayDevice,
                    FormatDeviceId(monitor.DeviceId),
                    read.Ok ? "ok" : "failed",
                    read.Ok ? "0x" + read.Current.ToString("X2") : "unavailable",
                    read.Ok ? "0x" + read.Maximum.ToString("X2") : "unavailable",
                    read.Error
                );
            }

            Target target = ResolveTarget(collection, true);
            Console.WriteLine(
                "rv200=identified index={0} identity={1}",
                target.Monitor.Index,
                target.Identity
            );
        }
    }

    public static void GetInput()
    {
        using (MonitorCollection collection = EnumerateMonitors())
        {
            Target target = ResolveTarget(collection, true);
            string computer = target.Preflight.Current == WindowsInput
                ? "Windows"
                : target.Preflight.Current == MacInput ? "Mac" : "Unknown";
            Console.WriteLine(
                "rv200 input={0} value=0x{1:X2} max=0x{2:X2} identity={3}",
                computer,
                target.Preflight.Current,
                target.Preflight.Maximum,
                target.Identity
            );
        }
    }

    private static void SwitchKnownInput(
        uint value,
        string computer,
        bool requireReadable
    )
    {
        using (MonitorCollection collection = EnumerateMonitors())
        {
            Target target = ResolveTarget(collection, requireReadable);
            bool ok = SetVCPFeature(target.Monitor.Handle, InputSourceVcpCode, value);
            int error = ok ? 0 : Marshal.GetLastWin32Error();

            if (!ok)
            {
                throw new Win32Exception(error, "SetVCPFeature failed");
            }

            Console.WriteLine(
                "rv200 switch={0} value=0x{1:X2} api=accepted identity={2} preflight={3}",
                computer,
                value,
                target.Identity,
                target.Preflight.Ok ? "verified-max-0x0E" : "hardware-id-only"
            );
        }
    }

    public static void SwitchToWindows()
    {
        SwitchKnownInput(WindowsInput, "Windows", false);
    }

    public static void SwitchToMac()
    {
        SwitchKnownInput(MacInput, "Mac", true);
    }
}
'@
}

try {
    if ($args.Count -ne 0) {
        throw "Unexpected arguments."
    }

    switch ($Action.ToLowerInvariant()) {
        "probe" {
            if ($Computer) { throw "-Computer is not valid with Probe." }
            [DisplaySwitcherWindows]::Probe()
        }
        "getinput" {
            if ($Computer) { throw "-Computer is not valid with GetInput." }
            [DisplaySwitcherWindows]::GetInput()
        }
        "switch" {
            if ($Computer -ceq "Windows") {
                [DisplaySwitcherWindows]::SwitchToWindows()
            }
            elseif ($Computer -ceq "Mac") {
                [DisplaySwitcherWindows]::SwitchToMac()
            }
            else {
                throw "Switch requires -Computer Windows or -Computer Mac."
            }
        }
        default {
            throw "Invalid action. Use Probe, GetInput, or Switch."
        }
    }

    exit 0
}
catch {
    $exception = $_.Exception
    while ($exception.InnerException) {
        $exception = $exception.InnerException
    }
    [Console]::Error.WriteLine("error: " + $exception.Message)
    exit 1
}
