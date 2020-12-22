function Convert-EasitXMLToPsObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [xml]$Response
    )
    
    begin {
        Write-Verbose "$($MyInvocation.MyCommand) initialized"
    }
    
    process {
        $returnItem = New-Object PSObject
        if ($Response.Envelope.Body.GetItemsResponse) {
            Write-Verbose "XML contains GetItemsResponse"
            $returnItem | Add-Member -MemberType Noteproperty -Name "requestedPage" -Value "$($Response.Envelope.Body.GetItemsResponse.requestedPage)"
            $returnItem | Add-Member -MemberType Noteproperty -Name "totalNumberOfPages" -Value "$($Response.Envelope.Body.GetItemsResponse.totalNumberOfPages)"
            $returnItem | Add-Member -MemberType Noteproperty -Name "totalNumberOfItems" -Value "$($Response.Envelope.Body.GetItemsResponse.totalNumberOfItems)"
            foreach ($column in $Response.Envelope.Body.GetItemsResponse.Columns.GetEnumerator()) {
                Write-Verbose "Adding property $($column.InnerText) as Noteproperty to object"
                $returnItem | Add-Member -MemberType Noteproperty -Name "$($column.InnerText)" -Value $null
            }
            foreach ($item in $Response.Envelope.Body.GetItemsResponse.Items.GetEnumerator()) {
                foreach ($itemProperty in $item.GetEnumerator()) {
                    $itemPropertyName = "$($itemProperty.Name)"
                    Write-Verbose "itemPropertyName = $itemPropertyName"
                    $itemPropertyValue = "$($itemProperty.InnerText)"
                    Write-Verbose "itemPropertyValue = $itemPropertyValue"
                    Write-Verbose "Setting $itemPropertyName to $itemPropertyValue"
                    $returnItem."$itemPropertyName" = "$itemPropertyValue"
                    if ("$($itemProperty.InnerText)" -match ' \/ ') {
                        Write-Verbose "$($itemProperty.InnerText) -match '/'"
                        $tempPropertyValues = @()
                        $tempPropertyValues = $itemProperty.InnerText -split ' / '
                        Write-Verbose "tempPropertyValue with slashes = $tempPropertyValues"
                        $count = 1
                        foreach ($tempPropertyValue in $tempPropertyValues) {
                            Write-Verbose "${propertyName}_${count} = $tempPropertyValue"
                            if ("$($itemProperty.rawValue)" -notmatch 'null') {
                                Write-Verbose "Adding ${itemPropertyName}_${count} with value $tempPropertyValue"
                                $returnItem | Add-Member -MemberType Noteproperty -Name "${itemPropertyName}_${count}" -Value "$tempPropertyValue"
                            }
                            $count++
                        }
                        $returnItem."$itemPropertyName" = "customArrayList"
                    }
                }
                $returnItem
            }
        } elseif ($Response.Envelope.Body.ImportItemsResponse) {
            Write-Verbose "XML contains ImportItemsResponse"
            $importItemResult = "$($Response.Envelope.Body.ImportItemsResponse.ImportItemResult.result)"
            $returnItem | Add-Member -MemberType Noteproperty -Name "ImportItemResult" -Value "$importItemResult"
            foreach ($returnValue in $Response.Envelope.Body.ImportItemsResponse.ImportItemResult.ReturnValues.GetEnumerator()) {
                Write-Verbose "Name = $($returnValue.name)"
                Write-Verbose "Value = $($returnValue.InnerText)"
                $returnItem | Add-Member -MemberType Noteproperty -Name "$($returnValue.name)" -Value "$($returnValue.InnerText)"
            }
            $returnItem
        } elseif ($Response.Envelope.Body.PingResponse) {
            Write-Verbose "XML contains PingResponse"
            foreach ($pingProperty in $Response.Envelope.Body.PingResponse.GetEnumerator()) {
                $returnItem | Add-Member -MemberType Noteproperty -Name "$($pingProperty.name)" -Value "$($pingProperty.InnerText)"
            }
            $returnItem
        } else {
            throw "Do not know what to do with XML"
        }
    }
    
    end {
        Write-Verbose "$($MyInvocation.MyCommand) completed"
    }
}