# Variables
$resourceGroup = "rg-bluesky"
$location = "EastUS"
$templateFile = "bluesky-main.bicep"

# Create Resource Group (if it doesn't exist)
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Host "Creating resource group $resourceGroup..." -ForegroundColor Cyan
    New-AzResourceGroup -Name $resourceGroup -Location $location
}

# Deploy Bicep template
Write-Host "Deploying BlueSky Intranet Lab..." -ForegroundColor Cyan
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroup `
    -TemplateFile $templateFile `
    -Verbose

Write-Host "Deployment complete." -ForegroundColor Green
