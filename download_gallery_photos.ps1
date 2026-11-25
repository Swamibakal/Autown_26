# Downloads event photos (with people) from the AUTOwn'25 website gallery
# into frontend\assets\images\gallery\ and shrinks them to max 1600 px wide.
# Run from the project folder:  powershell -ExecutionPolicy Bypass -File .\download_gallery_photos.ps1

$ErrorActionPreference = "Stop"
$base = "https://bits-pilani-wilp.ac.in/autown/images/"
$dir  = Join-Path $PSScriptRoot "frontend\assets\images\gallery"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

# file on the website  ->  name used by the new site (see "gallery" in content.json)
$photos = [ordered]@{
  "gallery_01.jpg" = "WILP0054.jpg"   # group photo
  "gallery_02.jpg" = "WILP0059.jpg"   # closing ceremony / gathering
  "gallery_03.jpg" = "WILP0299.jpg"   # keynote speaker
  "gallery_04.jpg" = "WILP0439.jpg"   # panel discussion
  "gallery_05.jpg" = "WILP0280.jpg"   # student participants
  "gallery_06.jpg" = "WILP0286.jpg"   # participant interaction
  "gallery_07.jpg" = "WILP0417.jpg"   # attendees at exhibits
  "gallery_08.jpg" = "WILP0425.jpg"   # hands-on workshop
  "gallery_09.jpg" = "WILP0609.jpg"   # interactive learning session
  "gallery_10.jpg" = "WILP0804.jpg"   # AI & mobility workshop
}

Add-Type -AssemblyName System.Drawing
$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$params = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]82)

foreach ($name in $photos.Keys) {
  $url  = $base + $photos[$name]
  $tmp  = Join-Path $env:TEMP ("autown_" + $photos[$name])
  $dest = Join-Path $dir $name
  Write-Host "Downloading $url"
  Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing

  $img = [System.Drawing.Image]::FromFile($tmp)
  $w = [Math]::Min(1600, $img.Width)
  $h = [int]($img.Height * $w / $img.Width)
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($img, 0, 0, $w, $h)
  $bmp.Save($dest, $jpeg, $params)
  $g.Dispose(); $bmp.Dispose(); $img.Dispose()
  Remove-Item $tmp
  Write-Host ("  saved {0} ({1} KB)" -f $name, [int]((Get-Item $dest).Length / 1KB))
}
Write-Host "Done. Check the photos in $dir and delete any you don't want (also remove them from content.json)."
