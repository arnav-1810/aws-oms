<# 
	This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
#>
workflow mod2 {
   Param($input)
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	$output =  inlineScript {
        $input1 = $using:input
        $accesskey = Get-AutomationVariable -Name '$access_key'
    		$secretkey = Get-AutomationVariable -Name 'secret_key'
    		$OMSWorkspacename = Get-AutomationVariable -Name 'OMSwkspname'
    		$resourcegroupname = Get-AutomationVariable -Name 'OMSrgname'
    		$customerId = Get-AutomationVariable -Name 'customerid'
    		$sharedKey = Get-AutomationVariable -Name 'sharedkey'
    		$profile_name = Get-AutomationVariable -Name 'profilename'
    		$region = Get-AutomationVariable -Name 'region'
        		Import-Module AWSPowerShell
 				Set-AWSCredentials -AccessKey $accesskey -SecretKey $secretkey -StoreAs $profile_name
 				Initialize-AWSDefaults -ProfileName $profile_name -Region $region
		$json10 = Get-CWMetricStatistics -MetricName $input1 -Dimension @{Name = "InstanceId"; Value = "i-08b290d4ab98f79c3"} -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date) -Namespace "AWS/EC2" -Period 1200 -Statistic Average | Select-Object -ExpandProperty Datapoints | ConvertTo-Json
        		$json = $json10 | ConvertFrom-Json | ForEach-Object { 
    		$_ | Add-Member -MemberType NoteProperty -Name 'ObjectName' -Value $input1 -PassThru
        
	} | ConvertTo-Json
    Write-Output $json
	#; $json}
  # "x=$json" 
      } 
      return $output
}