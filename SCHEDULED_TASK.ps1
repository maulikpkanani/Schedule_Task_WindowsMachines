####################### CONFIG ##########################
# Credentials to be configured in the scheduled task
$USER = "domain\user"
$PASS ="pass*word"

# Scheduled task name
$TASKNAME = "Daily Script"

# Scheduled task folder
$TASKPATH = "MyTasks"

# Scheduled task description
$DESCRIPTION = "This is my task description"

# Script to schedule
$SCRIPT="C:\SCRIPTS\daily_script.bat"
########################################################

Function CreateScheduledTaskFolder ($TASKPATH)
{
    $ERRORACTIONPREFERENCE = "stop"
    $SCHEDULE_OBJECT = New-Object -ComObject schedule.service
    $SCHEDULE_OBJECT.connect()
    $ROOT = $SCHEDULE_OBJECT.GetFolder("\")
    Try {$null = $SCHEDULE_OBJECT.GetFolder($TASKPATH)}
    Catch { $null = $ROOT.CreateFolder($TASKPATH) }
    Finally { $ERRORACTIONPREFERENCE = "continue" } 
}


Function CreateScheduledTask ($TASKNAME, $TASKPATH)
{
    $ACTION = New-ScheduledTaskAction -Execute "$SCRIPT"
    $TRIGGER =  New-ScheduledTaskTrigger -Daily -At 3am
    Register-ScheduledTask -Action $ACTION -Trigger $TRIGGER -TaskName $TASKNAME -Description "$DESCRIPTION" -TaskPath $TASKPATH -RunLevel Highest
}

Function ConfigureScheduledTaskSettings ($TASKNAME, $TASKPATH)
{
    $SETTINGS = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -RestartCount 3
    Set-ScheduledTask -TaskName $TASKNAME -Settings $SETTINGS -TaskPath $TASKPATH 
}

CreateScheduledTaskFolder $TASKNAME $TASKPATH
CreateScheduledTask $TASKNAME $TASKPATH | Out-Null
ConfigureScheduledTaskSettings $TASKNAME $TASKPATH | Out-Null

$PASSWORD = ConvertTo-SecureString "$PASS" -AsPlainText -Force
$CREDENTIALS = New-Object -typename System.Management.Automation.PSCredential -argumentlist $USER, $PASSWORD
 
Set-ScheduledTask -TaskName "$TASKNAME" -TaskPath "$TASKPATH" -User "$USER" -Password "$PASS" | Out-Null