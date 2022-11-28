Write-Host "Install SQL express engine"

Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkID=866658" -o "$PWD\sqlsetup.exe"
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/ACTION=install")
$args.Add("/Q")
$args.Add("/IACCEPTSQLSERVERLICENSETERMS")
Write-Host "Installing SQL Express silently..."
Start-Process -FilePath "$PWD\sqlsetup.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru

Write-Host "SQL engine installed"