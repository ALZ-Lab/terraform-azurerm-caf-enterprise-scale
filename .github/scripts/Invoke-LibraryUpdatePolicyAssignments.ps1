#!/usr/bin/pwsh

#
# PowerShell Script
# - Update template library in terraform-azurerm-caf-enterprise-scale repository
#

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()][String]$AlzToolsPath = "$PWD/enterprise-scale/src/Alz.Tools",
    [Parameter()][String]$TargetPath = "$PWD/terraform-azurerm-caf-enterprise-scale",
    [Parameter()][String]$SourcePath = "$PWD/enterprise-scale",
    [Parameter()][String]$LineEnding = "unix",
    [Parameter()][Switch]$Reset,
    [Parameter()][Switch]$UpdateProviderApiVersions
)

$ErrorActionPreference = "Stop"

# This script relies on a custom set of classes and functions
# defined within the EnterpriseScaleLibraryTools PowerShell
# module.
Import-Module $AlzToolsPath -ErrorAction Stop

$parser = "$TargetPath/.github/scripts/Template.Parser.Cli.exe"

# Update the policy assignments if enabled
Write-Information "Updating Policy Assignments." -InformationAction Continue
$policyAssignmentSourcePath = "$SourcePath/eslzArm/managementGroupTemplates/policyAssignments"
$policyAssignmentTargetPath = "$TargetPath/modules/archetypes/lib/policy_assignments"
$sourcePolicyAssignmentFiles = Get-ChildItem -Path $policyAssignmentSourcePath -File
$targetPolicyAssignmentFiles = Get-ChildItem -Path $policyAssignmentTargetPath -File

$parsedAssignments = @{}
foreach($sourcePolicyAssignmentFile in $sourcePolicyAssignmentFiles)
{
    $parsedAssignment = & $parser $sourcePolicyAssignmentFile | Out-String | ConvertFrom-Json
    Write-Host $parsedAssignment.name
    $parsedAssignments[$parsedAssignment.name] = @{
        json = $parsedAssignment
        file = $sourcePolicyAssignmentFile
    }
}

$originalAssignments = @{}
foreach($targetPolicyAssignmentFile in $targetPolicyAssignmentFiles)
{
    $originalAssignment = Get-Content $targetPolicyAssignmentFile | ConvertFrom-Json
    Write-Host $originalAssignment.name
    $originalAssignments[$originalAssignment.name] = @{
        json = $originalAssignment
        file = $targetPolicyAssignmentFile
    }
}

foreach($key in $parsedAssignments.Keys | Sort-Object)
{
    $targetPolicyAssignmentFileName = "policy_assignment_es_$($key.ToLower() -replace "-", "_").tmpl.json"
    Write-Host $targetPolicyAssignmentFileName
    if($originalAssignments.ContainsKey($key))
    {
        #Write-Host "Found match for $key $($originalAssignments[$key].file)"
    }
    else
    {
        #Write-Host "No match found for $key"
    }

    $json = $parsedAssignments[$key].json | ConvertTo-Json -Depth 10
    # $json | Edit-LineEndings -LineEnding $LineEnding | Out-File -FilePath "$policyAssignmentTargetPath/$targetPolicyAssignmentFileName" -Force
}
