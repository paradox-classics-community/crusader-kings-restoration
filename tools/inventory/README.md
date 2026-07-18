# CK1 Inventory Tool

Run from the Crusader Kings Complete installation directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\ck1-inventory.ps1
```

Or specify the installation explicitly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\ck1-inventory.ps1 `
  -GameRoot "C:\Program Files (x86)\Steam\steamapps\common\Crusader Kings"
```

The script writes an inventory directory and ZIP archive to the Desktop.

It does not copy original game assets. Review generated metadata before publishing.
