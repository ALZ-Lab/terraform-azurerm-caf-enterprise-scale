#!/usr/bin/pwsh

#
# PowerShell Script
# - Generate Azure Pipelines Strategy
#

Write-Host "==> Generating Azure Pipelines Strategy Matrix..."

$jsonDepth = 4
$terraformUrl = "https://api.github.com/repos/hashicorp/terraform/tags"
$azurermProviderUrl = "https://registry.terraform.io/v1/providers/hashicorp/azurerm"

########################################
# Terraform Versions
# - Base Version: "0.13.2"
# - Latest Versions:
#     0.13.* (latest 1)
#     0.14.* (latest 3)
#     0.15.* (latest 1)
########################################

$terraformVersionsResponse = Invoke-RestMethod -Method Get -Uri $terraformUrl
$terraformVersionsAll = $terraformVersionsResponse.name -replace "v", ""

$terraformVersions = @("0.13.2")
$terraformVersions += $terraformVersionsAll | Where-Object { $_ -match "^0.13" } | Select-Object -First 1
$terraformVersions += $terraformVersionsAll | Where-Object { $_ -match "^0.14" } | Select-Object -First 3
# Terraform v0.15.x currently causes validation errors. Needs further investigation.
# $terraformVersions += $terraformVersionsAll | Where-Object { $_ -match "^0.15" } | Select-Object -First 1

$terraformVersions = $terraformVersions | Sort-Object

#######################################
# Terraform AzureRM Provider Versions
# - Base Version: (2.34.0)
# - Latest Versions: (latest 1)
#######################################

$azurermProviderVersionBase = "2.34.0"
$azurermProviderVersionLatest = (Invoke-RestMethod -Method Get -Uri $azurermProviderUrl).version

#############################################################################
# Set a multi-job output variable to control strategy matrix for test jobs.
#############################################################################

$matrixObject = [PSCustomObject]@{}
for ($i = 0; $i -lt $terraformVersions.Count; $i++) {
    $terraformVersion = $terraformVersions[$i]
    $job1 = ($i * 2) + 1
    $job2 = ($i * 2) + 2
    $matrixObject | Add-Member `
        -NotePropertyName "$job1. (TF: $terraformVersion, AZ: $azurermProviderVersionBase)" `
        -NotePropertyValue @{
        TF_VERSION    = $terraformVersion;
        TF_AZ_VERSION = $azurermProviderVersionBase
    }
    $matrixObject | Add-Member `
        -NotePropertyName "$job2. (TF: $terraformVersion, AZ: $azurermProviderVersionLatest)" `
        -NotePropertyValue @{
        TF_VERSION    = $terraformVersion;
        TF_AZ_VERSION = $azurermProviderVersionLatest
    }
}

# Convert PSCustomObject to JSON.
$matrixJsonOutput = $matrixObject | ConvertTo-Json -Depth $jsonDepth -Compress

# Save the matrix value to an output variable for downstream consumption .
Write-Host "##vso[task.setVariable variable=matrix_json;isOutput=true]$matrixJsonOutput"
