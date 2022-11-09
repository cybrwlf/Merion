Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ErrorActionPreference = 'SilentlyContinue'
$wshell = New-Object -ComObject Wscript.Shell
$Button = [System.Windows.MessageBoxButton]::YesNoCancel
$ErrorIco = [System.Windows.MessageBoxImage]::Error
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

$WPFInstallUpgrade.Add_Click({
	$isUpgradeSuccess = $false
	try {
		Start-Process powershell.exe -Verb RunAs -ArgumentList "-command winget upgrade --all  | Out-Host" -Wait -WindowStyle Normal
		$isUpgradeSuccess = $true
	}
	catch [System.InvalidOperationException] {
		Write-Warning "Allow Yes on User Access Control to Upgrade"
	}
	catch {
		Write-Error $_.Exception
	}
	$ButtonType = [System.Windows.MessageBoxButton]::OK
	$Messageboxbody = if ($isUpgradeSuccess) { "Upgrade Done" } else { "Upgrade was not succesful" }
	$MessageIcon = [System.Windows.MessageBoxImage]::Information

	[System.Windows.MessageBox]::Show($Messageboxbody, $AppTitle, $ButtonType, $MessageIcon)
})

$WPFinstall.Add_Click({
	$wingetinstall = New-Object System.Collections.Generic.List[System.Object]

		$wingetinstall.Add("Adobe.Acrobat.Reader.64-bit")
		$wingetinstall.Add("Google.Chrome")
		$wingetinstall.Add("7zip.7zip")
	#	Possible future Install
	#	$wingetinstall.Add("Microsoft.WindowsTerminal")
	#	$wingetinstall.Add("Malwarebytes.Malwarebytes")
	#	$wingetinstall.Add("Rufus.Rufus")
	#	$wingetinstall.Add("TeamViewer.TeamViewer")
	#	$wingetinstall.Add("Microsoft.Teams")
	#	$wingetinstall.Add("JAMSoftware.TreeSize.Free")
	#	$wingetinstall.Add("Microsoft.VisualStudio.2022.Community")
		$wingetinstall.Add("Zoom.Zoom")

# GUI Specs
Write-Host "Checking winget..."

# Check if winget is installed
if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe){
    'Winget Already Installed'
}  
else {
	#Gets the computer's information
	$ComputerInfo = Get-ComputerInfo

	#Gets the Windows Edition
	$OSName = if ($ComputerInfo.OSName) {
		$ComputerInfo.OSName
	}else {
		$ComputerInfo.WindowsProductName
	}

	if (((($OSName.IndexOf("LTSC")) -ne -1) -or ($OSName.IndexOf("Server") -ne -1)) -and (($ComputerInfo.WindowsVersion) -ge "1809")) {
		
		Write-Host "Running Alternative Installer for LTSC/Server Editions"

		# Switching to winget-install from PSGallery from asheroto
		# Source: https://github.com/asheroto/winget-installer
		
		Start-Process powershell.exe -Verb RunAs -ArgumentList "-command irm https://raw.githubusercontent.com/asheroto/winget-installer/master/winget-install.ps1 | iex | Out-Host" -WindowStyle Normal
		
	}
	elseif (((Get-ComputerInfo).WindowsVersion) -lt "1809") {
		#Checks if Windows Version is too old for winget
		Write-Host "Winget is not supported on this version of Windows (Pre-1809)"
	}
	else {
		#Installing Winget from the Microsoft Store
		Write-Host "Winget not found, installing it now."
		Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
		$nid = (Get-Process AppInstaller).Id
		Wait-Process -Id $nid
		Write-Host "Winget Installed"
	}
}





# Install all winget programs in new window
$wingetinstall.ToArray()
# Define Output variable
$wingetResult = New-Object System.Collections.Generic.List[System.Object]
foreach ( $node in $wingetinstall ) {
	try {
		Start-Process powershell.exe -Verb RunAs -ArgumentList "-command winget install -e --accept-source-agreements --accept-package-agreements --silent $node | Out-Host" -WindowStyle Normal
		$wingetResult.Add("$node`n")
		Start-Sleep -s 3
		Wait-Process winget -Timeout 90 -ErrorAction SilentlyContinue
	}
	catch [System.InvalidOperationException] {
		Write-Warning "Allow Yes on User Access Control to Install"
	}
	catch {
		Write-Error $_.Exception
	}
}
$wingetResult.ToArray()
$wingetResult | ForEach-Object { $_ } | Out-Host

# Popup after finished
$ButtonType = [System.Windows.MessageBoxButton]::OK
if ($wingetResult -ne "") {
	$Messageboxbody = "Installed Programs `n$($wingetResult)"
}
else {
	$Messageboxbody = "No Program(s) are installed"
}
$MessageIcon = [System.Windows.MessageBoxImage]::Information

[System.Windows.MessageBox]::Show($Messageboxbody, $AppTitle, $ButtonType, $MessageIcon)

Write-Host "================================="
Write-Host "---  Installs are Finished    ---"
Write-Host "================================="




$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(1050,1000)
$Form.text                       = "Windows Toolbox By Chris Titus"
$Form.StartPosition              = "CenterScreen"
$Form.TopMost                    = $false
$Form.BackColor                  = [System.Drawing.ColorTranslator]::FromHtml("#e9e9e9")
$Form.AutoScaleDimensions     = '192, 192'
$Form.AutoScaleMode           = "Dpi"
$Form.AutoSize                = $True
$Form.AutoScroll              = $True
$Form.ClientSize              = '1050, 1000'
$Form.FormBorderStyle         = 'FixedSingle'
