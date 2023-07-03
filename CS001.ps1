# Please provide the following details:
$subscriptionId = "YourSubscriptionId"
$resourceGroupName = "YourResourceGroupName"
$keyVaultName = "YourKeyVaultName"
$certificateName = "YourCertificateName"
$excelFilePath = "C:\Path\to\YourExcelFile.xlsx"

# Connect to Azure and select the subscription
Connect-AzAccount
Set-AzContext -SubscriptionId $subscriptionId

# Retrieve the digital certificate from Azure Key Vault
$certificateSecret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $certificateName
$certificateBytes = [Convert]::FromBase64String($certificateSecret.SecretValueText)
$certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificateBytes)

# Retrieve the password for the digital certificate from Azure Key Vault
$passwordSecret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "CertificatePassword"
$certificatePassword = $passwordSecret.SecretValueText

# Load the Excel COM object
$excel = New-Object -ComObject Excel.Application

try {
    # Open the Excel file
    $workbook = $excel.Workbooks.Open($excelFilePath)

    # Sign the workbook using the digital certificate
    $workbook.Signatures.Add() | Out-Null
    $signature = $workbook.Signatures.Item(1)
    $signature.Setup($certificate, $certificatePassword)
    $signature.Sign()

    # Save and close the workbook
    $workbook.Save()
    $workbook.Close()

    Write-Host "Excel file signed successfully."
}
catch {
    Write-Host "An error occurred while signing the Excel file: $($_.Exception.Message)"
}
finally {
    # Quit Excel application
    $excel.Quit()

    # Release COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($signature) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

    # Clear variables
    Remove-Variable excel
    Remove-Variable certificate
    Remove-Variable certificatePassword
}
