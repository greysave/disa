
class CohesityCluster
{
    [String]$ClusterFQDN
    
    [String]Cluster-Auth([credential]$Cred, [string]$FQDN){
        $Auth-URL = $FQDN + "/irisservices/api/v1/public/accessTokens"
        $Header = @{
            'Authorization' = "Bearer AccessToken",
            'Accept' = "application/json",
            'Content-Type' = "application/json"
            }


        # Invoke-RestMethod -Method 'Post' -Header $Header -URL $Auth-URL -credential $Cred
        return $Token
    }
}

class CreateView 
{
    [String]$ViewName
    [INT]$Increment
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
    }
    if ($UserChoice -eq 2)
    {
        Write-Host "Enter the name you would like for the views:" -ForegroundColor Green -BackgroundColor Black
        $ViewName = Read-Host
        Write-Host "Please enter the number of shares that you would like to create:"
    }
} While ($UserChoice -ne 3)





