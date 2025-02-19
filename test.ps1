Add-Type -TypeDefinition @"
using System.Windows.Forms;
public class MsgBox {
    public static void Show() {
        MessageBox.Show("Test validé", "Confirmation", 0x40);
    }
}
"@ -Language CSharp

[MsgBox]::Show()
