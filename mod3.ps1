<# 
	This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
#>
workflow mod3 {
   Param($output)
  # "x=$output"
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	inlineScript {
       # “Workflow variable A is: $using:output”
      $json = $Using:output
      
	 $accesskey = Get-AutomationVariable -Name '$access_key'
    	$OMSWorkspacename = Get-AutomationVariable -Name 'OMSwkspname'
    		$resourcegroupname = Get-AutomationVariable -Name 'OMSrgname'
    		$customerId = Get-AutomationVariable -Name 'customerid'
    		$sharedKey = Get-AutomationVariable -Name 'sharedkey'
    		$profile_name = Get-AutomationVariable -Name 'profilename'
    		$region = Get-AutomationVariable -Name 'region'
    	$LogType = "awscompiled"
				 #Specify a field with the created time for the records
			$TimeStampField = "DateValue"
	#	Create the function to create the authorization signature
			Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
				{
    			$xHeaders = "x-ms-date:" + $date
    				$stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource
				
    			$bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    				$keyBytes = [Convert]::FromBase64String($sharedKey)
				
    				$sha256 = New-Object System.Security.Cryptography.HMACSHA256
    			$sha256.Key = $keyBytes
    			$calculatedHash = $sha256.ComputeHash($bytesToHash)
    				$encodedHash = [Convert]::ToBase64String($calculatedHash)
    				$authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    			return $authorization
			}
				
				
				# Create the function to create and post the request
				Function Post-OMSData($customerId, $sharedKey, $body, $logType)
				{
    				$method = "POST"
    	$contentType = "application/json"
    			$resource = "/api/logs"
    			$rfc1123date = [DateTime]::UtcNow.ToString("r")
    			$contentLength = $body.Length
    				$signature = Build-Signature `
       -customerId $customerId `
       -sharedKey $sharedKey `
       -date $rfc1123date `
       -contentLength $contentLength `
       -fileName $fileName `
       -method $method `
       -contentType $contentType `
       -resource $resource
    				$uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"
				
    			$headers = @{
        			"Authorization" = $signature;
        				"Log-Type" = $logType;
        				"x-ms-date" = $rfc1123date;
        				"time-generated-field" = $TimeStampField;
}
				
$response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
  				return $response.StatusCode
				
			}
				
#				Submit the data to the API endpoint
			Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType
	}
}