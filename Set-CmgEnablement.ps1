$CmgFqdn = 'CMGFQDN.com' #'CmgFQDN.com'    #Update with CMG FQDN

#Sets the internet MP in the client settings not really needed since we specify in the registry but I like it
$CMGName = "$($CmgFqdn)/CCM_Proxy_MutualAuth/232"
$SMS = New-Object -ComObject 'Microsoft.SMS.Client'
$SMS.SetInternetManagementPointFQDN($CMGName)

#Define the clients CMG behavior
$RegPath = 'HKLM:\Software\Microsoft\CCM'

If(Test-Path $RegPath){
    Set-ItemProperty -Path $RegPath -Name 'CMGFQDNs' -Value $CmgFqdn -Force | Out-Null #Pre-define the CMG FQDN
    Set-ItemProperty -Path $RegPath -Name 'DisAllowCMG' -Value 0 -Force | Out-Null #Ensuring the CMG is allowed
    Set-ItemProperty -Path $RegPath\Security -Name 'ClientAlwaysOnInternet' -value 1 | Out-Null #this should only be used for clients that will never connect to the intranet
    Restart-Service CcmExec -Force
}
Else{
    New-Item -Path $RegPath -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name 'CMGFQDNs' -Value $CmgFqdn -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name 'DisAllowCMG' -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name 'ClientAlwaysOnInternet' -Value 1 -PropertyType DWORD -Force | Out-Null
    
    #ready for client install now
}
