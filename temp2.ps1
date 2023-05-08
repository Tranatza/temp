# Load the SharePoint Online Management Shell module
Import-Module Microsoft.Online.SharePoint.PowerShell

# Set the URL of the SharePoint site and library
$siteUrl = "https://your-tenant.sharepoint.com/sites/your-site"
$libraryName = "Documents"

# Set the local path of the file you want to upload
$filePath = "C:\path\to\file.txt"

# Authenticate to SharePoint using Connect-SPOService
Connect-SPOService -Url $siteUrl

# Get the destination library in SharePoint
$library = Get-SPOList -Identity $libraryName

# Get the file name from the local file path
$fileName = Split-Path $filePath -Leaf

# Read the contents of the file
$fileContent = Get-Content $filePath -Encoding Byte

# Upload the file to SharePoint
$uploadInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
$uploadInfo.ContentStream = [System.IO.MemoryStream]::new($fileContent)
$uploadInfo.URL = $fileName
$uploadInfo.Overwrite = $true
$uploadResult = $library.RootFolder.Files.Add($uploadInfo)

# Output success message
Write-Host "File uploaded to SharePoint successfully."

# Disconnect from SharePoint
Disconnect-SPOService
