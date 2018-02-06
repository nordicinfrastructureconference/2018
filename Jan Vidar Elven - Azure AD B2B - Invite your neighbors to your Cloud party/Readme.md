# Details on Demos used for Azure AD B2B session

This readme file has some input on the usage of demos used in the Azure AD B2B session.

## AzureAD B2B Invite with PowerShell

The commands requires the Azure AD PowerShell Module (V2).

## AzureAD B2B Invite with Microsoft Graph

The provided JSON file sample shows the correct construct when sending an Azure AD B2B invite using Microsoft Graph API. For testing, and as shown in the demo in the session, use the Graph Explorer (http://aka.ms/ge).

In Graph Explorer sign in with your own user (Global Admin or user with Guest Inviter Role), and then do a POST request to https://graph.microsoft.com/v1.0/invitations, using the JSON construct as body with your own values.

## Enable Guest Users in Tenant Picker

The PowerShell commands shown in the SPOTenantSiteGuestPicker.ps1 file shows how to connect to SharePoint Online using SharePoint Management Shell (must be downloaded and installed on your computer), and enable tenant settings for enabling to show existing guest users in user picker, as well as for existing SPO sites. 