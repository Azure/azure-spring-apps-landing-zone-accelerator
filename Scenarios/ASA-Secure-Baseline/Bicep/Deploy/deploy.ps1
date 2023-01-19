$timeStamp = Get-Date -Format "yyyyMMddHHmm"
$location = $Args[0]
$namePrefix = $Args[1]

Set-Location ..
Get-ChildItem -Directory | ForEach-Object {
	Write-Warning  $_.FullName
	Set-Location $_.FullName

    if(Test-Path -Path "$($_.FullName)\main.bicep") {

        az deployment sub create --name "$($timeStamp)-$(Split-Path -Path $PWD -Leaf)" --location $location --template-file "main.bicep" --parameters parameters.json location=$location namePrefix=$namePrefix

        if ($lastexitcode -ne 0) { exit }
  
        # Wait 150 seconds between Apply
        #Write-Warning "Waiting 15 seconds...."
        #Start-Sleep 15
    }
}