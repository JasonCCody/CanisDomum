#Install-Module Microsoft.Graph -Force #Install if needed
#Import-Module Microsoft.Graph.Applications, Microsoft.Graph.Identity.SignIns #import if needed

$tenantID = '<Your Tenant ID>'
Connect-MgGraph -TenantId $tenantID -NoWelcome

$IssuancePolicies = Get-MgPolicyTokenIssuancePolicy

foreach($policy in $IssuancePolicies){

    #Determine "SigningAlgorithm"
    $Definition = $policy.Definition
    $PolicyID = $policy.Id
    
    Write-Host "Enumerating policy ID: $($PolicyID)"
    if($Definition -match 'sha1'){
        $SigningAlgorithm = 'sha1'
        Write-Host "WARNING! This policy is applying a $($SigningAlgorithm) signing algorithm!" -ForegroundColor Red
    }
    elseif ($Definition -match 'sha256') {
        $SigningAlgorithm = 'sha256'
        Write-Host "This policy is applying a $($SigningAlgorithm) signing algorithm" -ForegroundColor Green
    }
    else {
        $SigningAlgorithm = 'other'
        Write-Host "Caution! This policy is applying an undetermined signing algorithm and should be reviewed" -ForegroundColor Yellow
    }
    
    #Get applicaitons using SAML SSO
    $Apps = Get-MgPolicyTokenIssuancePolicyApplyTo -TokenIssuancePolicyId $PolicyID

    If($null -ne $Apps){
        foreach($AppSPN in $Apps.Id){
            $SPN = Get-MgServicePrincipal -ServicePrincipalId $AppSPN
            Write-Host "Found SPN for ""$($spn.DisplayName)"" using ""$($SigningAlgorithm)"", AppID: $($spn.AppId), ObjectID: $($spn.Id)"
        }
    }
    else {
        Write-Host "No applications identified using this policy"
    }
}
