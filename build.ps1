param(
    [string]$version
)
$Path = "Release"
if (Test-Path $Path)
	{
	Remove-Item -Path "$Path" -Recurse
	}
# ----------- MelonLoader IL2CPP Interop (net6) -----------
dotnet build src/LimbusLocalize_ml_ilcpp.sln -c ML
# Full
New-Item -Path "$Path" -Name "LimbusLocalize" -ItemType "directory" -Force
New-Item -Path "$Path/LimbusLocalize" -Name "Mods" -ItemType "directory" -Force
New-Item -Path "$Path/LimbusLocalize/Mods" -Name "Localize" -ItemType "directory" -Force
Copy-Item -Path Localize/CN $Path/LimbusLocalize/Mods/Localize -Force -Recurse
Copy-Item -Path Localize/Readme $Path/LimbusLocalize/Mods/Localize -Force -Recurse
Copy-Item -Path $Path/LimbusLocalize.dll -Destination $Path/LimbusLocalize/Mods -Force
7z a -t7z "$Path/LimbusLocalize_$version.7z" "./$Path/LimbusLocalize/*" -mx=9 -ms
$tag=$(git describe --tags --abbrev=0)
$changedFiles=$(git diff --name-only HEAD $tag -- Localize/CN/)
$changedFiles2=$(git diff --name-only HEAD $tag -- Localize/Readme/)
# OTA
New-Item -Path "$Path" -Name "LimbusLocalize_OTA" -ItemType "directory" -Force
New-Item -Path "$Path/LimbusLocalize_OTA" -Name "Mods" -ItemType "directory" -Force
Copy-Item -Path $Path/LimbusLocalize.dll -Destination $Path/LimbusLocalize_OTA/Mods -Force
New-Item -Path "$Path/LimbusLocalize_OTA/Mods" -Name "Localize" -ItemType "directory" -Force
New-Item -Path "$Path/LimbusLocalize_OTA/Mods/Localize" -Name "Readme" -ItemType "directory" -Force
New-Item -Path "$Path/LimbusLocalize_OTA/Mods/Localize" -Name "CN" -ItemType "directory" -Force
# Copy the changed files to the release directory
$changedFilesList = $changedFiles -split " "
foreach ($file in $changedFilesList) {
    if (Test-Path -Path $file) {
        $destination = "$Path/LimbusLocalize_OTA/Mods/Localize/CN/$file"
        $destination = $destination.Replace("Localize/CN/Localize/CN/", "Localize/CN/")
        $destinationDirectory = Split-Path -Path $destination -Parent
        if (!(Test-Path -Path $destinationDirectory)) {
            New-Item -ItemType Directory -Force -Path $destinationDirectory
        }
        Copy-Item -Path $file -Destination $destination -Force -Recurse
    }
}
$changedFilesList2 = $changedFiles2 -split " "
foreach ($file2 in $changedFilesList2) {
	if(Test-Path $file2){
		Copy-Item -Path $file2 $Path/LimbusLocalize_OTA/Mods/Localize/Readme -Force
    }
}
7z a -t7z "$Path/LimbusLocalize_OTA_$version.7z" "./$Path/LimbusLocalize_OTA/*" -mx=9 -ms