
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
        $Token = Invoke-RestMethod -Method 'Post' -URI $AuthURL -Header $Header -Body ($Body | ConvertTo-Json -Depth 99) -SkipCertificateCheck
        Write-Host "Authentication Successful" -ForegroundColor Green 
        return $Token.accessToken
    }
}

class CohesityView 
{
    [String]$ViewName
    [String]$ViewToken
    [Int]$Increment
    [String]$FQDN
    [String]$BearerToken
    [String]$StorageDomainName
    [Int]$StorageDomainID
    [String]$ContentType = "application/json"
    [String]$CSVPath
    [String]$PolicyName1
    [String]$PolicyID1
    [String]$PolicyName2
    [String]$PolicyID2
    [int]$ViewID
    [System.Object[]]$Cluster
    [String]$RemoteViewName
    
    

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
        
            $Views = Invoke-RestMethod -Method 'Post' -URI $CreateViewURL -Header $Header -Body ($Body | ConvertTo-Json -Depth 99) -SkipCertificateCheck
            Write-Host $Views.name  "Created successfully" -ForegroundColor Green 
        }
    }

    [Void]CreateListView()
    {
        $CreateViewURL = "https://" + $This.FQDN + "/irisservices/api/v1/public/views"
         
        $Header = @{
            "Authorization" = "Bearer " + $This.BearerToken
            "Accept" = $This.ContentType
            "Content-Type" = $This.ContentType
            }
        if ((Test-Path -Path $This.CSVPath) -eq $true)
        {
            $This.Cluster = $This.GetCluster()
            
            Import-Csv $This.CSVPath | ForEach-Object{
            $This.StorageDomainName = $_.StorageDomainName
            $This.StorageDomainID = $This.GetStorageDomain()
            $This.PolicyName1= $_.PolicyName1
            $This.PolicyID1 = $This.GetPolicy($This.PolicyName1)
            $This.PolicyName2 = $_.PolicyName2
            $This.PolicyID2 = $This.GetPolicy($This.PolicyName2)
            $This.ViewName = $_.ViewName
            $This.RemoteViewName = $_.RemoteViewName
            $Body = @{
                "name" = $_.ViewName
                "viewBoxId" = $This.StorageDomainID
                "enableNfsViewDiscovery" = $true
                "protocolAccess" = "kNFSOnly"
                "qos" = @{
                    "principalName" = "TestAndDev High"
                }
                }
            $Views = Invoke-RestMethod -Method 'Post' -URI $CreateViewURL -Header $Header -Body ($Body | ConvertTo-Json -Depth 99) -SkipCertificateCheck
            Write-Host $Views.name  "Created successfully" -ForegroundColor Green
            $This.ViewID = $This.GetView([String]$_.ViewName) 
            $This.ProtectView($This.ViewName + "_status", $This.PolicyID1)
            $This.ProtectView($This.ViewName + "_backup", $This.PolicyID2)

            # write-host $viewID
            }
        
        }   
        else
        {
            Write-Host "`n  You did not enter a valid path.  Please reslect option 1 through 4: `n" -ForegroundColor Green 
            return
        } 
    }
    
    [Void]ProtectView([String]$JobName, [String]$PolicyID){
        $Header = @{
            "Authorization" = "Bearer " + $This.BearerToken
            "Accept" = $This.ContentType
            "Content-Type" = $This.ContentType
            }
        
        $ProtectViewURL = "https://" + $This.FQDN + "/v2/data-protect/protection-groups"
        $ProtectViewBody = @{
            "name" = $JobName;
            "policyId"=  $PolicyID;
            "storageDomainId" = $This.StorageDomainID;
            "viewBoxId" = $This.StorageDomainID;
            "environment" = "kView";
            "viewName" = $This.ViewName;
            "startTime" = @{
                "hour" = 8;
                "minute" = 0;
                "timezone" = $This.Cluster.timezone
              };
              "viewParams" = @{ 
                  "objects"= @(
                    @{
                    "id" = $This.ViewID;
                    "name" = $This.ViewName
                    }
                );
                "replicationParams"= @{
                    "viewNameConfigList" = @(
                        @{
                        "sourceViewId" = $This.ViewID;
                        "useSameViewName" = $false;
                        "viewName" = $This.RemoteViewName
                        }
                    )
                };
            }
        }
        $ProtectView = Invoke-RestMethod -Method 'Post' -URI $ProtectViewURL -Header $Header -Body ($ProtectViewBody | ConvertTo-Json -Depth 99) -SkipCertificateCheck
        Write-Host $ProtectView.name "protection job successfully created" -ForegroundColor Green
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

    [String]GetPolicy([String]$PolicyName)
    {
        $Header = @{
            "Authorization" = "Bearer " + $This.BearerToken
            "Accept" = $This.ContentType
            "Content-Type" = $This.ContentType
            } 
        $PolicyGetURL = "https://" + $This.FQDN + "/irisservices/api/v1/public/protectionPolicies"
        $PolicyResponse = Invoke-RestMethod -Method 'Get' -URI $PolicyGetURL -Header $Header -SkipCertificateCheck
        $Policy = $PolicyResponse | where-object name -eq $PolicyName
        Return $Policy.id
    }

   
    [System.Object[]]GetCluster()
    {
        $Header = @{
            "Authorization" = "Bearer " + $This.BearerToken
            "Accept" = $This.ContentType
            "Content-Type" = $This.ContentType
            }
        $ClusterGetURL = "https://" + $This.FQDN + "/irisservices/api/v1/public/cluster"
        $ClusterInfo = Invoke-RestMethod -Method 'Get' -URI $ClusterGetURL -Header $Header -SkipCertificateCheck
        
        return $ClusterInfo
    }

    [Int64]GetView([String]$ViewNames) 
    {
        $Header = @{
            "Authorization" = "Bearer " + $This.BearerToken
            "Accept" = $This.ContentType
            "Content-Type" = $This.ContentType
            } 
        $ViewGetURL = "https://" + $This.FQDN + "/irisservices/api/v1/public/views"
        $ViewResponse = Invoke-RestMethod -Method 'Get' -URI $ViewGetURL -Header $Header -SkipCertificateCheck
        # $Views = $ViewResponse | where-object name -eq $ViewNames
        $Views = $ViewResponse.views | where-object name -eq $ViewNames
        Return $Views.viewId
    }
}
Do
{
    Write-Host "Select an option 1 through 4: 
    `n Enter 1 to authenticate to the Cohesity cluster.
    `n Enter 2 to create the new Cohesity Views.
    `n Enter 3 to create Cohesity Views based upon a list.
    `n Enter 4 to exit this application." -ForegroundColor Green 
    $UserChoice = Read-Host

    if ( $UserChoice -eq 1)
    {
        Write-Host "Enter the Cohesity cluster FQDN:" -ForegroundColor Green 
        $ClusterFQDN= Read-Host
        $Cluster = New-Object CohesityCluster
        $Cluster.FQDN = $ClusterFQDN
        Write-Host "Please enter the Cluster credentials:" -ForegroundColor Green 
        $Cluster.Cred = Get-Credential

        $ClusterToken = $Cluster.ClusterAuth()
    }
    elseif ($UserChoice -eq 2)
    {        
        try
        {
        $View = New-Object CohesityView
        $View.BearerToken = $ClusterToken
        $View.FQDN = $ClusterFQDN
        }
        catch
        {
            Write-Host "You have not authenticated to the cluster.  Please choose option 1 and authenticate to the cluster"  -ForegroundColor Green
        }

        Write-Host "Enter the name you would like for the views:" -ForegroundColor Green 
        $View.ViewName  = Read-Host
        Write-Host "Enter the number of views that you would like to create:" -ForegroundColor Green 
        $View.Increment = Read-Host
        Write-Host "Enter the storage domain to create the views on:" -ForegroundColor Green 
        $View.StorageDomainName = Read-Host
        
        $View.StorageDomainID = $View.GetStorageDomain()
        $View.CreateView()
    }
    elseif ($UserChoice -eq 3)
    {
        try 
        {
            $View = New-Object CohesityView
            
        }
        catch
        {
            Write-Host "You have not authenticated to the cluster.  Please choose option 1 and authenticate to the cluster"  -ForegroundColor Green
        }
        $View.FQDN = $ClusterFQDN
        $View.BearerToken = $ClusterToken

        Write-Host "Please enter the path and name of the CSV: `n" -ForegroundColor Green
        $View.CSVPath = Read-Host

        $View.CreateListView()
    }
    elseif ($userChoice -eq 4)
    {
        Write-Host "Goodbye" -ForegroundColor Green
    }
    else
    { 
        Write-Host "You have made an invalid selection.  Choose options 1 through 3 only." -ForegroundColor Green 
    }
} While ($UserChoice -ne 4)
