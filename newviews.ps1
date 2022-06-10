
class CohesityCluster
{
    [String]$FQDN
    [PSCredential]$Cred
    
    [String]ClusterAuth(){
        $AuthURL = "https://" + $This.FQDN + "/irisservices/api/v1/public/accessTokens"
        $ContentType = "application/json"
        
        $Header = @{
            "Accept" = $ContentType
            "Content-Type" = $ContentType
            }

        $Body = @{
            "username" = $This.Cred.username
            "password" = $This.Cred.GetNetworkCredential().password
        }
        $Token = Invoke-RestMethod -Method 'Post' -URI $AuthURL -Header $Header -Body ($Body | ConvertTo-Json) -SkipCertificateCheck
        Write-Host "Authentication Successful" -ForegroundColor Green -BackgroundColor Black
        return $Token.accessToken
    }
}

class CohesityView 
{
    [String]$ViewName
    [INT]$Increment
    [String]$FQDN
    [String]$BearerToken
    [String]$StorageDomainName
    [Int]$StorageDomainID
    [String]$ContentType = "application/json"
   

    [Void]CreateView()
    {
        $Header = @{
            "Authorization" = "Bearer " + $This.BearerToken
            "Accept" = $This.ContentType
            "Content-Type" = $This.ContentType
            }

        $CreateViewURL = "https://" + $This.FQDN + "/irisservices/api/v1/public/views"
        For ($counter = 1; $counter -le $This.Increment; $counter++)
        {
        $Body = @{
            "name" = $This.ViewName + "_" + $counter
            "viewBoxId" = $This.StorageDomainID
            "enableNfsViewDiscovery" = $true
            "protocolAccess" = "kNFSOnly"
            "qos" = @{
                "principalName" = "TestAndDev High"
            }
        }
        
            $Views = Invoke-RestMethod -Method 'Post' -URI $CreateViewURL -Header $Header -Body ($Body | ConvertTo-Json) -SkipCertificateCheck
            Write-Host $Views.name  "Created successfully" -ForegroundColor Green -BackgroundColor Black
        }
    }

    [Int]GetStorageDomain() 
    {
        $Header = @{
            "Authorization" = "Bearer " + $This.BearerToken
            "Accept" = $This.ContentType
            "Content-Type" = $This.ContentType
            } 
        $SDGetURL = "https://" + $This.FQDN + "/irisservices/api/v1/public/viewBoxes"
        $SDResponse = Invoke-RestMethod -Method 'Get' -URI $SDGetURL -Header $Header -SkipCertificateCheck  
        $SD = $SDResponse | where-object name -eq $This.StorageDomainName
        Return $SD.id
    }
}

Do
{
    Write-Host "Select an option 1 through 3: 
    `n Enter 1 to authenticate to the Cohesity cluster.
    `n Enter 2 to create the new Cohesity Views.
    `n Enter 3 to exit this application." -ForegroundColor Green -BackgroundColor Black
    $UserChoice = Read-Host

    if ( $UserChoice -eq 1)
    {
        Write-Host "Enter the Cohesity cluster FQDN:" -ForegroundColor Green -BackgroundColor Black
        $ClusterFQDN= Read-Host
        $Cluster = New-Object CohesityCluster
        $Cluster.FQDN = $ClusterFQDN
        Write-Host "Please enter the Cluster credentials:" -ForegroundColor Green -BackgroundColor Black
        $Cluster.Cred = Get-Credential

        $ClusterToken = $Cluster.ClusterAuth()
    }
    elseif ($UserChoice -eq 2)
    {        
        $View = New-Object CohesityView
        $View.BearerToken = $ClusterToken
        $View.FQDN = $ClusterFQDN

        Write-Host "Enter the name you would like for the views:" -ForegroundColor Green -BackgroundColor Black
        $View.ViewName  = Read-Host
        Write-Host "Enter the number of views that you would like to create:" -ForegroundColor Green -BackgroundColor Black
        $View.Increment = Read-Host
        Write-Host "Enter the storage domain to create the views on:" -ForegroundColor Green -BackgroundColor Black
        $View.StorageDomainName = Read-Host
        
        $View.StorageDomainID = $View.GetStorageDomain()
        $View.CreateView()
    }
    else
    {
        Write-Host "You have made an invalid selection.  Choose options 1 through 3 only." -ForegroundColor Green -BackgroundColor Black
    }
} While ($UserChoice -ne 3)
