# Dismiss WC3 "press any key to continue" splash by clicking the game window.
# Usage: run right after `python build/wc3.py go .`
# Exit 0 = focused and clicked, 1 = WC3 not found or focus not acquired.

param(
    [int]$WaitSec = 18,
    [int]$MaxAttempts = 5
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wc3Input {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }
    public const int SW_RESTORE = 9;
    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;

    public static bool IsForeground(IntPtr hWnd) {
        return hWnd != IntPtr.Zero && GetForegroundWindow() == hWnd;
    }

    public static bool FocusWindow(IntPtr hWnd) {
        if (hWnd == IntPtr.Zero) return false;
        if (IsIconic(hWnd)) ShowWindow(hWnd, SW_RESTORE);

        IntPtr foreground = GetForegroundWindow();
        uint fgThread = GetWindowThreadProcessId(foreground, out _);
        uint targetThread = GetWindowThreadProcessId(hWnd, out _);
        uint curThread = GetCurrentThreadId();

        bool attachedFg = false;
        bool attachedTarget = false;
        try {
            if (fgThread != 0 && fgThread != curThread) {
                attachedFg = AttachThreadInput(curThread, fgThread, true);
            }
            if (targetThread != 0 && targetThread != curThread) {
                attachedTarget = AttachThreadInput(curThread, targetThread, true);
            }
            BringWindowToTop(hWnd);
            SetForegroundWindow(hWnd);
        } finally {
            if (attachedTarget) AttachThreadInput(curThread, targetThread, false);
            if (attachedFg) AttachThreadInput(curThread, fgThread, false);
        }
        return IsForeground(hWnd);
    }

    public static void Click(int x, int y) {
        SetCursorPos(x, y);
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero);
    }
}
"@

Write-Host "Waiting ${WaitSec}s for WC3 splash..."
Start-Sleep -Seconds $WaitSec

$proc = Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessName -eq "Warcraft III" -and $_.MainWindowHandle -ne [IntPtr]::Zero } |
    Select-Object -First 1

if (-not $proc) {
    Write-Error "Warcraft III window not found"
    exit 1
}

$hwnd = $proc.MainWindowHandle
Write-Host "Found Warcraft III (pid $($proc.Id), hwnd $hwnd)"

$focused = $false
for ($i = 1; $i -le $MaxAttempts; $i++) {
    if ([Wc3Input]::FocusWindow($hwnd)) {
        $focused = $true
        Write-Host "Foreground acquired (attempt $i/$MaxAttempts)"
        break
    }
    Write-Host "Foreground not acquired yet (attempt $i/$MaxAttempts)..."
    Start-Sleep -Milliseconds 600
}

if (-not $focused) {
    Write-Error "Could not bring Warcraft III to foreground; click skipped to avoid hitting another window"
    exit 1
}

Start-Sleep -Milliseconds 200

if (-not [Wc3Input]::IsForeground($hwnd)) {
    Write-Error "Warcraft III lost foreground before click; click skipped"
    exit 1
}

$rect = New-Object Wc3Input+RECT
[Wc3Input]::GetWindowRect($hwnd, [ref]$rect) | Out-Null
$x = [int](($rect.Left + $rect.Right) / 2)
$y = [int](($rect.Top + $rect.Bottom) / 2)

[Wc3Input]::Click($x, $y)
Write-Host "Clicked active WC3 window at ($x, $y)"
exit 0
