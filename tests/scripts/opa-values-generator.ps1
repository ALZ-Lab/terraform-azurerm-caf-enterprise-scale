#!/usr/bin/pwsh

###############################################
# Run tests and generate testing values.
###############################################

# Run this locally to test your terraform configuration and generate the values needed for the automation pipeline.
# The script will install all the necessary components locally and run the tests.
# After completing the tests, follow the script prompt for the next steps.

# # Parameters
$CONFIRM = "y"

# # #? Run a local test against a different module configuration:
# # #* Update the path to run the tests on a different folder (example: ../deployment_2)
# # #* Copy paste the variables.tf file from deployment folder and adjust your main.tf
###############################################
# # #* Path of the tested _es terraform module
$BASE_PATH = $(Get-Location).Path
$MODULE_PATHS = @(
    "$($BASE_PATH)/../modules/test_001_baseline"
    "$($BASE_PATH)/../modules/test_002_add_custom_core"
    "$($BASE_PATH)/../modules/test_003_add_mgmt_conn"
)
###############################################

$PWSH_OS = $PSVersionTable.OS
$PWSH_PLATFORM = $PSVersionTable.Platform

Write-Output "################################################"
Write-Output "==> Initiate installation of pre-requisites..."
Write-Output "==> OS       : $PWSH_OS"
Write-Output "==> Platform : $PWSH_PLATFORM"
Write-Output "`n"

if (($PWSH_OS -like "*Windows*") -and ($PWSH_PLATFORM -eq "Win32NT")) {
    ./opa-install-windows.ps1
}
elseif (($PWSH_OS -like "Darwin*") -and ($PWSH_PLATFORM -eq "Unix")) {
    Write-Output "Support for MacOS still in development. Please ensure pre-requisites are manually installed and re-run this script if errors occur due to missing software."
}
elseif (($PWSH_OS -like "Linux*") -and ($PWSH_PLATFORM -eq "Unix")) {
    source opa-install-linux.sh
}

Write-Output "`n"
Write-Output "==> Completed installation of pre-requisites."
Write-Output "################################################"
Write-Output "`n"

foreach ($MODULE_PATH in $MODULE_PATHS) {

    if (-not ($MODULE_PATH | Test-Path)) { Throw "The directory does not exist, check entries in MODULE_PATHS variable on .\opa-values-generator.ps1 :line 18" }

    $TF_PLAN_OUT = "$MODULE_PATH/terraform_plan"
    $PLANNED_VALUES = "$MODULE_PATH/planned_values"
    $MODULE_NAME = Split-Path $MODULE_PATH -Leaf

    Write-Output "==> ($MODULE_NAME) - Change to the module root directory..."
    Set-Location $MODULE_PATH

    Write-Output "==> ($MODULE_NAME) - Initializing infrastructure..."
    terraform init -upgrade

    Write-Output "==> ($MODULE_NAME) - Planning infrastructure..."
    terraform plan `
        -var="root_id=root-id-1" `
        -var="root_name=root-name" `
        -var="primary_location=northeurope" `
        -var="secondary_location=westeurope" `
        -out="$TF_PLAN_OUT"

    Write-Output "==> ($MODULE_NAME) - Converting plan to *.json..."
    terraform show -json "$TF_PLAN_OUT" | Out-File -FilePath "$TF_PLAN_OUT.json"

    Write-Output "==> ($MODULE_NAME) - Removing the original plan..."
    Remove-Item -Path "$TF_PLAN_OUT"

    Write-Output "==> ($MODULE_NAME) - Saving planned values to a temporary planned_values.json..."
    Get-Content -Path "$TF_PLAN_OUT.json" | jq '.planned_values.root_module' | Out-File -FilePath "$PLANNED_VALUES.json"

    Write-Output "==> ($MODULE_NAME) - Converting to yaml..."
    Get-Content -Path "$PLANNED_VALUES.json" | yq e -P - | Tee-Object "$PLANNED_VALUES.yml"

    # # #  Run OPA Tests
    Set-Location $MODULE_PATH
    Write-Output "==> ($MODULE_NAME) - Running conftest..."

    Write-Output "==> ($MODULE_NAME) - Testing management_groups..."
    conftest test "$TF_PLAN_OUT.json" -p ../../opa/policy/management_groups.rego -d "$PLANNED_VALUES.yml"

    Write-Output "==> ($MODULE_NAME) - Testing role_definitions..."
    conftest test "$TF_PLAN_OUT.json" -p ../../opa/policy/role_definitions.rego -d "$PLANNED_VALUES.yml"

    Write-Output "==> ($MODULE_NAME) - Testing role_assignments..."
    conftest test "$TF_PLAN_OUT.json" -p ../../opa/policy/role_assignments.rego -d "$PLANNED_VALUES.yml"

    Write-Output "==> ($MODULE_NAME) - Testing policy_set_definitions..."
    conftest test "$TF_PLAN_OUT.json" -p ../../opa/policy/policy_set_definitions.rego -d "$PLANNED_VALUES.yml"

    Write-Output "==> ($MODULE_NAME) - Testing policy_definitions..."
    conftest test "$TF_PLAN_OUT.json" -p ../../opa/policy/policy_definitions.rego -d "$PLANNED_VALUES.yml"

    Write-Output "==> ($MODULE_NAME) - Testing policy_assignments..."
    conftest test "$TF_PLAN_OUT.json" -p ../../opa/policy/policy_assignments.rego -d "$PLANNED_VALUES.yml"

    # # # Remove comments and $CONFIRM parameter for CMD prompt.
    # # # $CONFIRM = Read-Host "Do you want to prepare files for repository (y/n)?"
    if ($CONFIRM -eq 'y') {
        Write-Output "`n"
        Remove-Item -Path "$TF_PLAN_OUT.json"
        Write-Output "==> ($MODULE_NAME) - $TF_PLAN_OUT.json has been removed"
        Write-Output "`n"
        Remove-Item -Path "$PLANNED_VALUES.yml"
        Write-Output "==> ($MODULE_NAME) - $PLANNED_VALUES.yml has been removed"
        Write-Output "`n"
    }
    else {
        Write-Warning -Message "($MODULE_NAME) - $TF_PLAN_OUT.json  can contain sensitive data"
        Write-Warning -Message  "($MODULE_NAME) - Exposing $TF_PLAN_OUT.json in a repository can cause security breach"
        Write-Output "`n"
        Write-Output "($MODULE_NAME) - From within your terraform root module: conftest test $TF_PLAN_OUT.json -p ../../opa/policy/  -d $PLANNED_VALUES.yml"
        Write-Output "`n"
    }

    Write-Output "==> ($MODULE_NAME) - Return to scripts directory..."
    Set-Location $BASE_PATH

}
