Push-Location
Set-Location $PSScriptRoot

$name = 'SSH'
$assembly = "Community.PowerToys.Run.Plugin.$name"
$version = "v$((Get-Content ./plugin.json | ConvertFrom-Json).Version)"
$archs = @('x64', 'arm64')
$tempDir = './out/SSH'

git tag $version
git push --tags

Remove-Item ./out/*.zip -Recurse -Force -ErrorAction Ignore
foreach ($arch in $archs) {
	$releasePath = "./bin/$arch/Release/net9.0-windows"

	dotnet build -c Release /p:Platform=$arch

	Remove-Item "$tempDir/*" -Recurse -Force -ErrorAction Ignore
	mkdir "$tempDir" -ErrorAction Ignore
	$items = @(
		"$releasePath/$assembly.deps.json",
		"$releasePath/$assembly.dll",
		"$releasePath/Glob.dll",
		"$releasePath/plugin.json",
		"$releasePath/Images",
		"$ReleasePath/uk-UA"
	)
	Copy-Item $items "$tempDir" -Recurse -Force
	Compress-Archive "$tempDir" "./out/$name-$version-$arch.zip" -Force
}

gh release create $version (Get-ChildItem ./out/*.zip)
Pop-Location
