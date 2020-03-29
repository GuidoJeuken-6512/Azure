# Script can be used to change azure B2C Attributs.
# you only have to change the values for the B2C Tentants to your values -> $envarray
# G.Jeuken 
# V1 29.03.2020

# customize your B2C tentants here
$envarray = @("YourB2CDev.onmicrosoft.com","YourB2CTest.onmicrosoft.com","YourProdB2C.onmicrosoft.com")
$environment = $envarray | Out-GridView -Title "Select Environment" -PassThru
if (!$environment) {exit} # stop hier if canceld or value is NULL
# we need this for the input-boxes 
Add-Type -AssemblyName Microsoft.VisualBasic


# check if connected / connect
if(!$azureConnection.Account){
    $azureConnection = Connect-AzureAD 
}

# connect to selected AzureB2C /ask for login if needed
connect-AzureAD -TenantId $environment -AccountId $azureConnection.Account  >$null 2>&1

# ask for users forename
$forename= [Microsoft.VisualBasic.Interaction]::InputBox('Enter the beginning of the users forename', 'Search for B2C User')
if (!$forename) {exit} # stop hier if canceld or value is NULL

# search for the user and show existing extentions

# build query to find user
$filter="startswith(GivenName,'"+$forename+"')"
#get user
$user = Get-AzureADUser -Filter $filter | Out-GridView -Title "Select User" -PassThru 
if (!$user) {exit} # stop hier if canceld or value is NULL
#get and show all extentions
$extentions = $user | Get-AzureADUser  | Get-AzureADUserExtension  | Out-GridView -Title "Select Extention to change" -PassThru
if (!$extentions) {exit} # stop hier if canceld or value is NULL

#ask for new Value
$textforinfobox= "New value for " + $extentions.name +   " old Value " + $extentions.Value
$newValue= [Microsoft.VisualBasic.Interaction]::InputBox($textforinfobox, 'input new value')
if (!$newValue) {exit} # stop hier if canceld or value is NULL

#set new value
Set-AzureADUserExtension -ObjectId $user.ObjectId -ExtensionName $extentions.Name -ExtensionValue $newvalue
$extentionNew=$user | Get-AzureADUser  | Get-AzureADUserExtension 
Clear-Host
Write-Host "User: " $user.DisplayName " Extention: " $extentions.Name " old Value: " $extentions.Value "changed to " 
$extentionNew  |Format-Table