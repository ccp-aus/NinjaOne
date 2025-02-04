
function Get-NinjaOneJobs {
    <#
        .SYNOPSIS
            Gets jobs from the NinjaOne API.
        .DESCRIPTION
            Retrieves jobs from the NinjaOne v2 API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Filter by job type.
        [String]$jobType,
        # Filter by device triggering the alert.
        [Alias('df')]
        [String]$deviceFilter,
        # Filter by language tag.
        [Alias('lang')]
        [String]$languageTag,
        # Filter by timezone.
        [Alias('ts')]
        [String]$timeZone,
        # Filter by device ID.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [Int]$deviceId
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'deviceid=' parameter by removing it from the set parameters.
    if ($deviceId) {
        $Parameters.Remove('deviceID') | Out-Null
    }
    try {
        $QSCollection = New-NinjaOneQuery -CommandName $CommandName -Parameters $Parameters
        if ($deviceId) {
            Write-Verbose 'Getting device from NinjaOne API.'
            $Device = Get-NinjaOneDevices -deviceID $deviceId
            if ($Device) {
                Write-Verbose "Retrieving jobs for $($Device.SystemName)."
                $Resource = "v2/device/$($deviceId)/jobs"
            }
        } else {
            Write-Verbose 'Retrieving all jobs.'
            $Resource = 'v2/jobs'
        }
        $RequestParams = @{
            Resource = $Resource
            QSCollection = $QSCollection
            NoDrill = $True
        }
        $JobResults = New-NinjaOneGETRequest @RequestParams
        Return $JobResults
    } catch {
        New-NinjaOneError -ErrorRecord $_
    }
}