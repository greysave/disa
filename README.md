# New Views

This app creates a user specified number of views using a user specified name plus the number.

1. Select Option 1 to choose enter a Cohesity cluster FQDN and to enter credentials to that cluster.
2. Select Option 2 to enter the new Views base name, number of views to create, and storage domain to store the views on.

```
# Download Commands

$scriptName = 'newviews.ps1’

$repoURL = '[https://raw.githubusercontent.com/greysave/disa/master/newviews.ps1?token=GHSAT0AAAAAABT2P3VYIEK4FPLB4DGWYILIYVB3SBQ](https://raw.githubusercontent.com/greysave/disa/master/newviews.ps1?token=GHSAT0AAAAAABT2P3VYIEK4FPLB4DGWYILIYVB3SBQ)'

(Invoke-WebRequest -Uri "$$repoUrl/$$scriptName/$$scriptName.ps1").content | Out-File "$$scriptName.ps1"; (Get-Content "$$scriptName.ps1") | Set-Content "$$scriptName.ps1"

(Invoke-WebRequest -Uri "$repoUrl/cohesity-api/cohesity-api.ps1").content | Out-File cohesity-api.ps1; (Get-Content cohesity-api.ps1) | Set-Content cohesity-api.ps1

# End Download Commands

```

