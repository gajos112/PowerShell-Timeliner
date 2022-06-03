<#
Published on Version_1.0_2022-06-03
Author: Krzysztof Gajewski
Github: https://github.com/gajos112/PowerShell-Timeliner
Blog: https://cyberdefnerd.com/
Linkedin: https://www.linkedin.com/in/krzysztof-gajewski-537683b9/

.NOTES
    Version 1.0 2022-06-03: First version released
#>

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")    
$cmd = [System.String]::Concat($PSScriptRoot,"\bin\LogParser.exe")

function GetTimelineLenght($OutputPathFile){
    try{
        if (Test-path $OutputPathFile){
            $size = (Get-content $OutputPathFile).length
            $TextBox_Logs.AppendText("Number of lines added to the timeline: $size`r`n")
        }
        else
        {
            $TextBox_Logs.AppendText("The file $OutputPathFile was not found!`r`n")
        }
    }
    catch{[System.Windows.Forms.MessageBox]::Show($_, "PowerShell Logs - Timeliner", 0)}
}

function Search{
    try{
        $keyword = $TextBox_Search.Text
            
            if($keyword){
                foreach ($row in $DataGridView_Logs.Rows)
                {
                    if (!$DataGridView_Logs.SelectedRows.Contains($row)){
                        if($row.Cells[4].Value -notmatch $keyword){
                            $row.Visible = $false
                        }
                    }
                }
            }
            else{
                foreach ($row in $DataGridView_Logs.Rows)
                {
                    if (!$DataGridView_Logs.SelectedRows.Contains($row)){
                            $row.Visible = $true
                    }
                }
            }
    }
    catch{[System.Windows.Forms.MessageBox]::Show($_, "PowerShell Logs - Timeliner", 0)}
}

function gridClick(){
    try{
        $rowIndex = $DataGridView_Logs.CurrentRow.Index
        $columnIndex = $DataGridView_Logs.CurrentCell.ColumnIndex

        $DataGridView_Logs.Rows[$rowIndex].Selected = $true

        $TextBox_RunspaceID.Text = $DataGridView_Logs.Rows[$rowIndex].Cells[0].value
        $TextBox_Started.Text = $DataGridView_Logs.Rows[$rowIndex].Cells[1].value
        $TextBox_EndedD.Text = $DataGridView_Logs.Rows[$rowIndex].Cells[2].value
        $TextBox_Duration.Text = $DataGridView_Logs.Rows[$rowIndex].Cells[3].value
        $TextBox_Path.Text = $DataGridView_Logs.Rows[$rowIndex].Cells[4].value
    }
    catch{[System.Windows.Forms.MessageBox]::Show($_, "PowerShell Logs - Timeliner", 0)}
}

function Parse{
    try{
        
        $Event_log_file_Directory = $TextBox_Input.Text
        $Output_Directory = $TextBox_Output.Text

        $Event_log_file = [System.String]::Concat($Event_log_file_Directory,"\Windows PowerShell.evtx")
        $LogPath = [System.String]::Concat($Output_Directory,"\PowerShellLogs.txt")

        $TextBox_Logs.AppendText("Input: $Event_log_file`r`n")
        $TextBox_Logs.AppendText("Output: $Output_Directory`r`n`r`n")

        if (Test-Path $Event_log_file){
            ### 403 ###

            $TextBox_Logs.AppendText("Parsing PowerShell.evtx: (ID 403) using 'logParser.exe'...`r`n")
        
            $OutputPathFileTmp = [System.String]::Concat($Output_Directory,"\Timeline_WinEvt_Powershell_403.tmp")
            $OutputPathFile = [System.String]::Concat($Output_Directory,"\Timeline_WinEvt_Powershell_403.csv")
            
            if(Test-Path $OutputPathFile)
            {
                Remove-Item -Path $OutputPathFile
                $TextBox_Logs.AppendText("The old timeline $OutputPathFile was deleted.`r`n")
            }

            "Date,Event" | Out-File $OutputPathFileTmp
        
            $command_Processes_Created_Select="Select TimeGenerated AS Date,',',message FROM "
            $command_Processes_Created_Where=" WHERE EventID = 403"
            $command_Processes_Created=[System.String]::Concat($command_Processes_Created_Select,"'",$Event_log_file,"'",$command_Processes_Created_Where)
            & $cmd -stats:OFF -i:EVT -q:ON -resolveSIDs:ON $command_Processes_Created  | out-File $OutputPathFileTmp -Append

            $RunspaceId403 = @()

            $CSV = Import-Csv $OutputPathFileTmp
            $CSV | ForEach-Object {

                $NewRow = [System.String]::Concat(([DateTime]$_.Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss"),",EVTX - PowerShell - 403,,", $_.Event.Trim());
                $Time = ([DateTime]$_.Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")

                $pattern = "HostApplication=(.*) EngineVersion.* RunspaceId=(.*) PipelineId="
                $matchcheck = $NewRow -match $pattern
                if ($matchcheck){
                     $ScriptName = $matches[1]
                     $ScriptRunspaceId = $matches[2]
                     $RunspaceId403 += [PSCustomObject]@{Date = $Time; Script = $ScriptName;  ID = $ScriptRunspaceId} 
                 }

                 Add-Content -Path $OutputPathFile -Value $NewRow
            }

            if(Test-Path $OutputPathFile)
            {
                $TextBox_Logs.AppendText("Timeline for events ID 403 was saved to: $OutputPathFile`r`n")
                GetTimelineLenght($OutputPathFile)
            }

            Remove-Item -Path $OutputPathFileTmp

            ### 400 ###

            $TextBox_Logs.AppendText("`r`nParsing PowerShell.evtx: (ID 400) using 'logParser.exe'...`r`n")
        
            $OutputPathFileTmp = [System.String]::Concat($Output_Directory,"\Timeline_WinEvt_Powershell_400.tmp")
            $OutputPathFile = [System.String]::Concat($Output_Directory,"\Timeline_WinEvt_Powershell_400.csv")
            
            if(Test-Path $OutputPathFile)
            {
                Remove-Item -Path $OutputPathFile
                $TextBox_Logs.AppendText("The old timeline $OutputPathFile was deleted.`r`n")
            }

            "Date,Event" | Out-File $OutputPathFileTmp
        
            $command_Processes_Created_Select="Select TimeGenerated AS Date,',',message FROM "
            $command_Processes_Created_Where=" WHERE EventID = 400"
            $command_Processes_Created=[System.String]::Concat($command_Processes_Created_Select,"'",$Event_log_file,"'",$command_Processes_Created_Where)
            & $cmd -stats:OFF -i:EVT -q:ON -resolveSIDs:ON $command_Processes_Created  | out-File $OutputPathFileTmp -Append

            $RunspaceId400 = @()

            $CSV = Import-Csv $OutputPathFileTmp
            $CSV | ForEach-Object {

                $NewRow = [System.String]::Concat(([DateTime]$_.Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss"),",EVTX - PowerShell - 400,,", $_.Event.Trim());
                $Time = ([DateTime]$_.Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")

                $pattern = "HostApplication=(.*) EngineVersion.* RunspaceId=(.*) PipelineId="
                $matchcheck = $NewRow -match $pattern
                if ($matchcheck){
                     $ScriptName = $matches[1]
                     $ScriptRunspaceId = $matches[2]
                     $RunspaceId400 += [PSCustomObject]@{Date = $Time; Script = $ScriptName;  ID = $ScriptRunspaceId} 
                 }
                 Add-Content -Path $OutputPathFile -Value $NewRow
            }

            if(Test-Path $OutputPathFile){
                $TextBox_Logs.AppendText("Timeline for events ID 400 was saved to: $OutputPathFile`r`n")
                GetTimelineLenght($OutputPathFile)
            }

            Remove-Item -Path $OutputPathFileTmp

            ### ANALYSIS ###
            $TextBox_Logs.AppendText("`r`nAnalyzing all logs...")

            $DataGridView_Logs.Enabled = $true
            $DataGridView_Logs.rows.clear()
            
            $check = 0
            $counter = 0
            $counter2 = 0
            foreach($itemin400 in $RunspaceId400)
                {
                    $check = 0
                    foreach($itemin403 in $RunspaceId403)
                        {
                        
                            if(($itemin403.ID -eq $itemin400.ID) -And ($itemin403.Script -eq $itemin400.Script)){

                                $StartDate = [DateTime] $itemin400.Date
                                $EndDate = [DateTime] $itemin403.Date
                                $Duration = NEW-TIMESPAN –Start $StartDate –End $EndDate
                            
                                $msg1 = [System.String]::Concat("Script Runspace Id: ", $itemin403.ID)
                                $msg2 = [System.String]::Concat("Script started on: ", $itemin400.Date)
                                $msg3 = [System.String]::Concat("Script ended on: ", $itemin403.Date)
                                $msg4 = [System.String]::Concat("Duration: ", $Duration.Hours, " hours ", $Duration.Minutes, " minutes ", $Duration.Seconds, " seconds")
                                $msg5 = [System.String]::Concat("Script path: ", $itemin403.Script,"`r`n")

                                if(Test-Path $LogPath){
                                    Remove-Item -Path $LogPath
                                }

                                Add-Content -Path $LogPath -Value $msg1
                                Add-Content -Path $LogPath -Value $msg2
                                Add-Content -Path $LogPath -Value $msg3
                                Add-Content -Path $LogPath -Value $msg4
                                Add-Content -Path $LogPath -Value $msg5

                                $duration = [System.String]::Concat($Duration.Hours, " hours ", $Duration.Minutes, " minutes ", $Duration.Seconds, " seconds")
                                $DataGridView_Logs.rows.Add($itemin403.ID, $itemin400.Date, $itemin403.Date, $duration, $itemin403.Script)
                                $counter += 1
                                $check = 1
                            }
                        }


                   if ($check -eq 0)
                    {
                        $DataGridView_Logs.rows.Add($itemin400.ID, $itemin400.Date, "", "", $itemin400.Script)
                        $counter2 += 1
                    }

                }

            $TextBox_Counter.Text = $counter
            $TextBox_Counter2.Text = $counter2

            if($DataGridView_Logs.RowCount -gt 0)
            {
                $Button_Search.Enabled = $true
            }                           
                if(Test-Path $LogPath){
                    $TextBox_Logs.AppendText("`r`nMatched logs were saved to: $LogPath`r`n")
                }
            }
        else{
            [System.Windows.Forms.MessageBox]::Show("The path to $Event_log_file was not found.", "PowerShell Logs Timeliner Error!", 0)
            }
        }
    
    catch
    {
        [System.Windows.Forms.MessageBox]::Show($_, "PowerShell Logs - Timeliner", 0)
    }
}

function About {
    $aboutForm          = New-Object System.Windows.Forms.Form
    $aboutFormExit      = New-Object System.Windows.Forms.Button
    $aboutFormImage     = New-Object System.Windows.Forms.PictureBox
    $aboutFormNameLabel = New-Object System.Windows.Forms.Label
    $aboutFormText      = New-Object System.Windows.Forms.Label
 
    $aboutForm.AcceptButton  = $aboutFormExit
    $aboutForm.CancelButton  = $aboutFormExit
    $aboutForm.ClientSize    = "410, 140"
    $aboutForm.ControlBox    = $false
    $aboutForm.ShowInTaskBar = $false
    $aboutForm.StartPosition = "CenterParent"
    $aboutForm.Text          = "About"

    $aboutFormImage.Image = [System.Drawing.Image]::FromFile($icon)
    $aboutFormImage.Location = "55, 15"
    $aboutFormImage.Size     = "32, 32"
    $aboutFormImage.SizeMode = "StretchImage"
    $aboutForm.Controls.Add($aboutFormImage)
 
    $aboutFormNameLabel.Location = "100, 20"
    $aboutFormNameLabel.Size     = "200, 18"
    $aboutFormNameLabel.Text     = "PowerShell Logs - Timeliner"
    $aboutForm.Controls.Add($aboutFormNameLabel)
 
    $aboutFormText.Location = "100, 50"
    $aboutFormText.Size     = "400, 40"
    $aboutFormText.Text     = "Author: Krzysztof Gajewski `n`rLink: https://github.com/gajos112"
    $aboutForm.Controls.Add($aboutFormText)

    $aboutFormExit.Location = "135, 100"
    $aboutFormExit.Text     = "OK"
    $aboutForm.Controls.Add($aboutFormExit)
 
    $aboutForm.ShowDialog() 
}

####################################### FRAME ####################################### 
$WindowsForm = New-Object System.Windows.Forms.Form
$WindowsForm.Text = "PowerShell Logs - Timeliner"
$WindowsForm.Size = New-Object System.Drawing.Size(1700,1000)
$WindowsForm.FormBorderStyle = "FixedDialog"

####################################### MENU #######################################
$menuMain = New-Object System.Windows.Forms.MenuStrip

$menuFile = New-Object System.Windows.Forms.ToolStripMenuItem
$menuFile.Text = "File"

$MenuExit = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuExit.Text  = "Exit"
$MenuExit.Add_Click({$WindowsForm.Close()})

$menuFile.DropDownItems.Add($MenuExit)

$menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHelp.Text = "Help"

$MenuInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuInfo.ShortcutKeys = "F1"
$MenuInfo.Text  = "PowerShell Logs - Timeliner"
$MenuInfo.Add_Click({About})

$menuHelp.DropDownItems.Add($MenuInfo)

$menuMain.Items.Add($menuFile)
$menuMain.Items.Add($menuHelp)

####################################### INPUT PATH #######################################
$Label_Input = New-Object System.Windows.Forms.Label
$Label_Input.Text = "Path to POWERSHELL Logs (winevt\Logs):"
$Label_Input.Location = '20,40'
$Label_Input.Size = '320,20'

$TextBox_Input = New-Object System.Windows.Forms.TextBox
$TextBox_Input.Location = '20,60'
$TextBox_Input.Size = '180,20'
$TextBox_Input.Readonly = $true
$TextBox_Input.Text = $null

$Button_Input = New-Object System.Windows.Forms.Button
$Button_Input.Location = '210,60'
$Button_Input.Size = '110,20'
$Button_Input.Text = 'Select path'

####################################### OUTPUT PATH (#######################################
$Label_Output = New-Object System.Windows.Forms.Label
$Label_Output.Text = "Save the output in:"
$Label_Output.Location = '20,85'
$Label_Output.Size = '280,20'

$TextBox_Output= New-Object System.Windows.Forms.TextBox
$TextBox_Output.Location = '20,105'
$TextBox_Output.Size = '180,20'
$TextBox_Output.Readonly = $true
$TextBox_Output.Text = $null

$Button_Output = New-Object System.Windows.Forms.Button
$Button_Output.Location = '210,105'
$Button_Output.Size = '110,20'
$Button_Output.Text = 'Select path'

####################################### EXTRACT BUTTON #######################################
$Button_Parse = New-Object System.Windows.Forms.Button
$Button_Parse.Location = '20,145'
$Button_Parse.Size = '300,20'
$Button_Parse.Text = 'Parse'

####################################### BUTTON ACTIONS #######################################
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

$Button_Input.Add_Click({
   $folderBrowser.ShowDialog()
   $TextBox_Input.Text = $folderBrowser.SelectedPath
})

$Button_Output.Add_Click({
   $folderBrowser.ShowDialog()
   $pathEvent_log_fileVar = $folderBrowser.SelectedPath
   $TextBox_Output.Text = $folderBrowser.SelectedPath
})

$Button_Parse.Add_Click({
    $inputPath = $TextBox_Input.Text

    if ($inputPath)
    {
        Parse
    }
    else 
    {
        [System.Windows.Forms.MessageBox]::Show("The path to the Powershell logs was not provided.","PowerShell Logs - Timeliner - error",0)
    }
})

####################################### INFORMATION #######################################
$Label_RunspaceID = New-Object System.Windows.Forms.Label
$Label_RunspaceID.Text = "Script Runspace ID:"
$Label_RunspaceID.Location = '350,20'
$Label_RunspaceID.Size = '140,20'

$TextBox_RunspaceID = New-Object System.Windows.Forms.TextBox
$TextBox_RunspaceID.Location = '490,20'
$TextBox_RunspaceID.Size = '330,20'
$TextBox_RunspaceID.Readonly = $true
$TextBox_RunspaceID.Text = $null
$TextBox_RunspaceID.BackColor = 'white'

$Label_Started = New-Object System.Windows.Forms.Label
$Label_Started.Text = "Started Time:"
$Label_Started.Location = '350,45'
$Label_Started.Size = '140,20'

$TextBox_Started = New-Object System.Windows.Forms.TextBox
$TextBox_Started.Location = '490,45'
$TextBox_Started.Size = '330,20'
$TextBox_Started.Readonly = $true
$TextBox_Started.Text = $null
$TextBox_Started.BackColor = 'white'

$Label_Ended = New-Object System.Windows.Forms.Label
$Label_Ended.Text = "Ended Time:"
$Label_Ended.Location = '350,70'
$Label_Ended.Size = '140,20'

$TextBox_EndedD = New-Object System.Windows.Forms.TextBox
$TextBox_EndedD.Location = '490,70'
$TextBox_EndedD.Size = '330,20'
$TextBox_EndedD.Readonly = $true
$TextBox_EndedD.Text = $null
$TextBox_EndedD.BackColor = 'white'

$Label_Duration = New-Object System.Windows.Forms.Label
$Label_Duration.Text = "Duration:"
$Label_Duration.Location = '350,95'
$Label_Duration.Size = '140,20'

$TextBox_Duration = New-Object System.Windows.Forms.TextBox
$TextBox_Duration.Location = '490,95'
$TextBox_Duration.Size = '330,20'
$TextBox_Duration.Readonly = $true
$TextBox_Duration.Text = $null
$TextBox_Duration.BackColor = 'white'

$Label_Path = New-Object System.Windows.Forms.Label
$Label_Path.Text = "Script Path:"
$Label_Path.Location = '350,120'
$Label_Path.Size = '140,20'

$TextBox_Path = New-Object System.Windows.Forms.TextBox
$TextBox_Path.Location = '490,120'
$TextBox_Path.Size = '330,60'
$TextBox_Path.Readonly = $true
$TextBox_Path.Text = $null
$TextBox_Path.BackColor = 'white'
$TextBox_Path.Multiline = $true

####################################### COUNTER #######################################
$Label_Counter = New-Object System.Windows.Forms.Label
$Label_Counter.Text = "Count of matched executions:"
$Label_Counter.Location = '20,182'
$Label_Counter.Size = '155,20'

$TextBox_Counter = New-Object System.Windows.Forms.TextBox
$TextBox_Counter.Location = '195,180'
$TextBox_Counter.Size = '50,20'
$TextBox_Counter.Readonly = $true
$TextBox_Counter.Text = $null
$TextBox_Counter.BackColor = 'white'

$Label_Counter2 = New-Object System.Windows.Forms.Label
$Label_Counter2.Text = "Count of unmatched executions:"
$Label_Counter2.Location = '20,207'
$Label_Counter2.Size = '175,20'

$TextBox_Counter2 = New-Object System.Windows.Forms.TextBox
$TextBox_Counter2.Location = '195,205'
$TextBox_Counter2.Size = '50,20'
$TextBox_Counter2.Readonly = $true
$TextBox_Counter2.Text = $null
$TextBox_Counter2.BackColor = 'white'

####################################### SEARCH #######################################
$Label_Search = New-Object System.Windows.Forms.Label
$Label_Search.Text = "Search for: :"
$Label_Search.Location = '350,198'
$Label_Search.Size = '60,20'

$TextBox_Search = New-Object System.Windows.Forms.TextBox
$TextBox_Search.Location = '410,195'
$TextBox_Search.Size = '150,20'
$TextBox_Search.Text = $null
$TextBox_Search.BackColor = 'white'

$Button_Search = New-Object System.Windows.Forms.Button
$Button_Search.Location = '570,193'
$Button_Parse.Size = '300,20'
$Button_Search.Text = 'Search'
$Button_Search.Enabled = $false
$Button_Search.Add_Click({Search})

####################################### LOGS #######################################
$TextBox_Logs= New-Object System.Windows.Forms.TextBox
$TextBox_Logs.Location = '850,40'
$TextBox_Logs.Size = '820,185'
$TextBox_Logs.Readonly = $true
$TextBox_Logs.Text = $null
$TextBox_Logs.Multiline = $true
$TextBox_Logs.BackColor = 'white'
$TextBox_Logs.ScrollBars = 'both'

####################################### TABLE #######################################
$DataGridView_Logs = New-Object System.Windows.Forms.DataGridView
$DataGridView_Logs.Location = '20,240'
$DataGridView_Logs.AutoSize = $false
$DataGridView_Logs.Size = '1650,705'
$DataGridView_Logs.ScrollBars = "Both"
$DataGridView_Logs.TabIndex = 0
$DataGridView_Logs.ColumnCount = 5
$DataGridView_Logs.ColumnHeadersVisible = $true
$DataGridView_Logs.Columns[0].Name = "Script Runspace Id:"
$DataGridView_Logs.Columns[1].Name = "Started"
$DataGridView_Logs.Columns[2].Name = "Completed"
$DataGridView_Logs.Columns[3].Name = "Duration"
$DataGridView_Logs.Columns[4].Name = "Script path"
$DataGridView_Logs.Columns[0].Width = '225'
$DataGridView_Logs.Columns[1].Width = '125'
$DataGridView_Logs.Columns[2].Width = '125'
$DataGridView_Logs.Columns[3].Width = '175'
$DataGridView_Logs.Columns[4].Width = '975'
$DataGridView_Logs.Enabled = $false
$DataGridView_Logs.Add_CellMouseClick({gridClick})

####################################### SHOW DIALOG #######################################
$WindowsForm.Controls.Add($Label_Input)
$WindowsForm.Controls.Add($TextBox_Input)
$WindowsForm.Controls.Add($Button_Input)
$WindowsForm.Controls.Add($Label_Output)
$WindowsForm.Controls.Add($TextBox_Output)
$WindowsForm.Controls.Add($Button_Output)
$WindowsForm.Controls.Add($Button_Parse)

$WindowsForm.Controls.Add($Label_RunspaceID)
$WindowsForm.Controls.Add($TextBox_RunspaceID)

$WindowsForm.Controls.Add($Label_Started)
$WindowsForm.Controls.Add($TextBox_Started)

$WindowsForm.Controls.Add($Label_Ended)
$WindowsForm.Controls.Add($TextBox_EndedD)

$WindowsForm.Controls.Add($Label_Duration)
$WindowsForm.Controls.Add($TextBox_Duration)

$WindowsForm.Controls.Add($Label_Path)
$WindowsForm.Controls.Add($TextBox_Path)

$WindowsForm.Controls.Add($Label_Counter)
$WindowsForm.Controls.Add($TextBox_Counter)

$WindowsForm.Controls.Add($Label_Counter2)
$WindowsForm.Controls.Add($TextBox_Counter2)

$WindowsForm.Controls.Add($Label_Search)
$WindowsForm.Controls.Add($TextBox_Search)
$WindowsForm.Controls.Add($Button_Search)

$WindowsForm.Controls.Add($TextBox_Logs)
$WindowsForm.Controls.Add($DataGridView_Logs)
$WindowsForm.Controls.Add($menuMain)
$WindowsForm.ShowDialog()

