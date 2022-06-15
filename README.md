# New Views

This app creates a user specified number of views using a user specified name plus the number.

1. Select Option 1 to choose enter a Cohesity cluster FQDN and to enter credentials to that cluster.
2. Select Option 2 to enter the new Views base name, number of views to create, and storage domain to store the views on.  This option is incomplete please do not select this option.
3.  Select Option 3 to create new Views from a list.  The list needs the following headings and is case sensitive:
- **ViewName** - The name of the View to be created.
- **StorageDomainName** - The name of the storage domain to create both the View and protection jobs on.
- **RemoteViewName** - Name of the View on the replicalica Cohesity cluster.
- **Policy** - that has replication to a remote cluster included.

```powershell
# Download Commands

$scriptName = 'newviews.ps1’

$repoURL = '[https://raw.githubusercontent.com/greysave/disa/master/]'
(Invoke-WebRequest -Uri "$$repoUrl/$$scriptName/$$scriptName.ps1").content | Out-File "$$scriptName.ps1"; (Get-Content "$$scriptName.ps1") | Set-Content "$$scriptName.ps1"
# End Download Commands

```

