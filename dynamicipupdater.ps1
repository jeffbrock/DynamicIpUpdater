$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$senderEmail = "[user]@gmail.com"
$recipientEmail = "[user]@gmail.com"
$dataFile = "[path to file persiting ip]"
$emailPassword = "[gmail smtp password]"

$subAndDomain = "[domain to update]"
$webRequestURI = "https://domains.google.com/nic/update"
$APIUserID = "[api user id]"
$APIPassword = "[api password]"
$securePassword = ConvertTo-SecureString -String $APIPassword -AsPlainText -Force
$dynamicDnsCredentials = New-Object System.Management.Automation.PSCredential ($APIUserID, $securePassword)

$publicIP = (Invoke-RestMethod -Uri "http://httpbin.org/ip").origin
$lastIp = Get-Content -Path $dataFile

if ($publicIP -ne $lastIp) {
	$params = @{}
	$params.Add("hostname", $subAndDomain)
	$params.Add("myip", $publicIP)
	$params.Add("offline", "no")
	$response = Invoke-WebRequest -uri $webRequestURI -Method Post -Body $params -Credential $dynamicDnsCredentials 

	$subject = "sendip " + $publicIP
	$body = "update dynamic dns: " + $Response.Content
	$secpasswd = ConvertTo-SecureString $emailPassword -AsPlainText -Force 
	$emailCredential = New-Object System.Management.Automation.PSCredential ($senderEmail, $secpasswd)
	Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $emailCredential -From $senderEmail -To $recipientEmail -Subject $subject -Body $body
	$publicIP | Out-File -FilePath $dataFile
}