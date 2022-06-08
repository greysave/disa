
class CohesityCluster
{
    [String]$ClusterFQDN
    
    [String]ClusterAuth([PSCredential]$Cred, [string]$FQDN){
        $AuthURL = "https://" + $FQDN + "/irisservices/api/v1/public/accessTokens"
        $ContentType = "application/json"
        
        $Header = @{
            "Accept" = $ContentType
            "Content-Type" = $ContentType
            }

        $Body = @{
            "username" = $Cred.username
            "password" = $Cred.GetNetworkCredential().password
        }
        $Token = Invoke-RestMethod -Method 'Post' -URI $AuthURL -Header $Header -Body ($Body | ConvertTo-Json) -SkipCertificateCheck
        return $Token.accessToken
    }
}

class CohesityView 
{
    [String]$ViewName
    [INT]$Increment

    [Void]CreateView([String]$BearerToken, [String]$FQDN)
    {
        $SDURL = "https://" + $FQDN + "/irisservices/api/v1/public/views"
        $ContentType = "application/json"
        
        $Header = @{
            "Authorization" = "Bearer $BearerToken"
            "Accept" = $ContentType
            "Content-Type" = $ContentType
            } 
        
        $Views = Invoke-RestMethod -Method 'Get' -URI $SDURL -Header $Header -SkipCertificateCheck
        Write-Host $Views
    }
}

Do
{
    Write-Host "Select an option: 
    `n Enter 1 to authenticate to the Cohesity cluster.
    `n Enter 2 to create the new Cohesity Views.
    `n Enter 3 to exit this application." -ForegroundColor Green -BackgroundColor Black
    $UserChoice = Read-Host

    if ( $UserChoice -eq 1)
    {
        Write-Host "Enter the Cohesity cluster FQDN:" -ForegroundColor Green -BackgroundColor Black
        $ClusterFQDN= Read-Host
        $Cluster = New-Object CohesityCluster
        $Cluster.ClusterFQDN = $ClusterFQDN
        Write-Host "Please enter the Cluster credentials:" -ForegroundColor Green -BackgroundColor Black
        $Credential = Get-Credential

        $ClusterToken = $Cluster.ClusterAuth($Credential, $ClusterFQDN )
    }
    if ($UserChoice -eq 2)
    {
        Write-Host "Enter the name you would like for the views:" -ForegroundColor Green -BackgroundColor Black
        $ViewName = Read-Host
        Write-Host "Please enter the number of shares that you would like to create:" -ForegroundColor Green -BackgroundColor Black
        $Increment = Read-Host

        $View = New-Object CohesityView
        $View.ViewName = $ViewName
        $View.Increment = $Increment
        $view.CreateView($ClusterToken, $ClusterFQDN)
    }
} While ($UserChoice -ne 3)





