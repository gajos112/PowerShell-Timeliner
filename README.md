# PowerShell-Timeliner

PowerShell Timeliner was designed and created for all DFIR analysts who want to parse PowerShell logs in order to get the duration time for executed scripts. The logs file is located in:

- C:\Windows\System32\winevt\Logs\Windows PowerShell.evtx

t is a GUI tool written in PowerShell. In order to parse Windows Event Logs it uses Log Parser 2.2, which can be downloaded from https://www.microsoft.com/en-us/download/details.aspx?id=24659. The executable has to be located in a directory named bin, which is locate din the same path as the script. If you download the version, which I realased in the GitHub page, then you only have to extract the content (Log Parser 2.2 is there) and it's ready to use. 

The tool generates three diffrent files. Two of them are CSV files and keep a TLN format timeline for two events:

- 400 (Engine state is changed from None to Available)
- 403 (Engine state is changed from Available to Stopped)

Inside the third file, you can find all processes which were matched (script execution was matched to script termination):

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/15.PNG?raw=true)

All three files are saved to the provided location:

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/14.PNG?raw=true)

# How does it work?

Like it was said erlier, it is the GUI tool which looks like that:

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/6_.png?raw=true)

First, you have to provide a path to the Windows PowerShell.evtx that you want to parse. Then you also have to provide the path where you want to save the output (timelines in TLN format, script executions) and click "PARSE".

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/10.PNG?raw=true)

The tool first parses all events with ID 400 and 403 and saves the output to two files:
- Timeline_WinEvt_Powershell_400.csv
- Timeline_WinEvt_Powershell_403.csv

Then it takes that two files and gathers basic information about script executions (event ID 400) and script terminations (event ID 403). It uses ScriptRunspaceId and script path two match these logs. If the ScriptRunspaceId and script path match, it puts that together and adds to a DataGridView to display that inforamtion in a very handy way, but it also writes it down to a file which will be named PowerShellLogs.txt.

To get more information about a script you are interted in, you can click on the row containg it and the tool will display all extracted information: 

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/7.PNG?raw=true)

In addition to that, I implemented a small logging panel, which tell you how many entire were added to the Timeline and where the output was saved.

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/12.PNG?raw=true)

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/13.PNG?raw=true)


