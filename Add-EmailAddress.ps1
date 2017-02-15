<#
    In my O365 setup, I have one admin user with no mailbox, with a UPN in the default domain ending with .onmicrosoft.com, and one mailbox with a UPN in my custom domain.
#>
param(
    [Parameter(Mandatory)]
    [string[]]$EmailAddresses,
    [string]$DefaultDomain
)

$EmailAddresses = $EmailAddresses | foreach {
    if ($_ -notmatch '@') {
        $_ + '@' + $DefaultDomain
    } else {$_}
}

Import-Module PoshSecret
$AdminPoshSecret = Get-PoshSecret | ?{$_.Name -eq 'O365' -and $_.Username -match 'onmicrosoft.com'}
$AdminCredential   = Get-PoshSecret -Name $AdminPoshSecret.Name -Username $AdminPoshSecret.UserName -AsPSCredential

$MailboxPoshSecret = Get-PoshSecret | ?{$_.Name -eq 'O365' -and $_.Username -notmatch 'onmicrosoft.com'}
$MailboxUpn = $MailboxPoshSecret.UserName

#Import-Module AzureRM
#Login-AzureRmAccount -Credential $AdminCredential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $AdminCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

#https://technet.microsoft.com/en-us/library/bb123794(v=exchg.160).aspx
Set-Mailbox $MailboxUpn -EmailAddresses @{add=$EmailAddresses}

#$Mailbox = Get-Mailbox $MailboxUpn
#$Mailbox.EmailAddresses

Remove-PSSession $Session

