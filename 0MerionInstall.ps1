
$Merion2Install = @(
    #Windows 10 Apps to install for Merion
    "Zoom.Zoom"
    "Google.Chrome"
    #"Microsoft.Teams"
	#"Microsoft.OneDrive"
	"7zip.7zip"
	#"Logitech.UnifyingSoftware"

	# Adobe Reader
	"XPDP273C0XHQH2"
	)


	
function InstallMerion()
{
    Write-Host "Installing Apps For Merion"

    foreach ($Item2Install in $Merion2Install) {
		
		Write-Host "Trying to install $Item2Install."
		$i2icheck =  Read-Host "Install "$Item2Install"? [Y/N]"
		$i2icheck = $i2icheck.ToUpper()
		
		if ( "Y" -eq $i2icheck ){
		winget install -e --id $Item2Install
        } else {
		Write-Warning "Not Installing $Item2Install"}
    }

    Write-Host "Finished Installing Apps For Merion"
}
InstallMerion