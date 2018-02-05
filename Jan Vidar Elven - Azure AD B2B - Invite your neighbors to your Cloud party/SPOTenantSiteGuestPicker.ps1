# Connect to SharePoint Online
Connect-SPOService -Url https://elven-admin.sharepoint.com 

# Enable to Show Guest Users in People Picker, Tenant default
Set-SPOTenant -ShowPeoplePickerSuggestionsForGuestUsers $true

# Enable to Show Guest Users in People Picker, for existing sites
Get-SPOSite | Select-Object Url, ShowPeoplePickerSuggestionsForGuestUsers

Set-SPOSite "https://elven.sharepoint.com" -ShowPeoplePickerSuggestionsForGuestUsers $true