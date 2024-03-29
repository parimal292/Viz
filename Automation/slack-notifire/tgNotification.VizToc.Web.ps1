try
{	
    Add-Type -AssemblyName System.Web	
    $ENV:APP_CHANGELOG = "..\..\src\Changelog.txt"
    $ENV:APP_NAME = "VizToc WEB"
		 
	$Env:APP_VERSION = (gc $ENV:APP_CHANGELOG -First 1)  
	$lines = (gc $ENV:APP_CHANGELOG -First 10 | select -first 10 -skip 1)
    $lineResult = [System.Collections.Arraylist]@()

    foreach ($line in $lines) 
    {
        if($line -eq ''){        
            break
        }
        else{
            $lineResult.Add($line)
        }    
    }

    $headers = @{
        "Content-Type" = "application/json; charset=utf-8"
        "Authorization" = "Bearer " + $args[0]
    }

    $body =@{
        "channel" = "general";
        "blocks" = [System.Collections.Arraylist]@(
		@{
			"type" = "section";
			"text" = @{
				"type" = "mrkdwn";
				"text" = "Hi @everyone :wave: *New Version* :mega::mega:"
			}
		};
        @{
			"type" = "section";
			"text" = @{
				"type" = "mrkdwn";
				"text" = "*Build" + $ENV:APP_NAME + " " + $Env:APP_VERSION + "* :white_check_mark:"
			}
		};
        @{
			"type" = "divider"
		};
        @{
			"type" = "section";
			"text" = @{
				"type" = "mrkdwn";
				"text" = "*Changes* :eyes:"
			}
		};
        @{
			"type" = "section";
			"text" = @{
				"type" = "mrkdwn";
				"text" = $lineResult -join "`r`n"
			}
		}) | ConvertTo-Json
    } | ConvertTo-Json

    $url = "https://slack.com/api/chat.postMessage"
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Method Post -Headers $headers -Body $body
    $responseObj = $response | ConvertFrom-Json
    if($responseObj.ok -eq 'true') {
        Write-Host "Message successfully sent"
    } else {
        Write-Host "Message successfully not sent"
    }
}
catch [System.Exception]
{
    $errType = $_.Exception.GetType().FullName
    $message = $_.Exception.Message

    Write-Host "ERROR: '$errType' '$message'" -ForegroundColor Red
    exit 1
}
