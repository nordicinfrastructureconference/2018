
# Connect Azure AD
Connect-AzureAD

# Connect to Azure AD specific tenant id
Connect-AzureAD -TenantId 104742fb-6225-439f-9540-60da5f0317dc

# Simple: Invite B2B User
# https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureadmsinvitation?view=azureadps-2.0

New-AzureADMSInvitation -InvitedUserDisplayName "Name (Company)" -InvitedUserEmailAddress "alias@domain.com" `
    -InviteRedirectUrl "https://myapps.microsoft.com" -SendInvitationMessage $true

# Advanced: Invite B2B User
# https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureadmsinvitation?view=azureadps-2.0

$messageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo
$messageInfo.customizedMessageBody = "Hi! You are invited to Elven Azure AD as a Guest with PowerShell!"
$messageInfo.MessageLanguage = "en-US"
$recipient = New-Object Microsoft.Open.MSGraph.Model.Recipient
$emailAddress = New-Object Microsoft.Open.MSGraph.Model.EmailAddress
$emailAddress.Name = "Jan Vidar"
$emailAddress.Address = "jan.vidar@elven.no"
$recipient.EmailAddress = $emailAddress
$messageInfo.CcRecipients = $recipient

$inviteRespons = New-AzureADMSInvitation -InvitedUserDisplayName "Name (Company)" -InvitedUserEmailAddress "alias@domain.com" `
    -InviteRedirectUrl "https://myapps.microsoft.com" -InvitedUserMessageInfo $messageInfo `
    -SendInvitationMessage $false -InvitedUserType "Guest"

# Look at Invite Response
$inviteRespons | Select-Object InviteRedeemUrl, Status

