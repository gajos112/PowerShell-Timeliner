# PowerShell-Timeliner

PowerShell Timeliner was designed and created for all DFIR analysts who want to parse PowerShell logs in order to get the duration time for executed scripts. The logs file is located in:

- C:\Windows\System32\winevt\Logs\Windows PowerShell.evtx

t is a GUI tool written in PowerShell. In order to parse Windows Event Logs it uses Log Parser 2.2, which can be downloaded from https://www.microsoft.com/en-us/download/details.aspx?id=24659. The executable has to be located in a directory named bin, which is locate din the same path as the script. If you download the version, which I realased in the GitHub page, then you only have to extract the content (Log Parser 2.2 is there) and it's ready to use. 

The tool generates three diffrent files. Two of them are CSV files and keep a TLN format timeline for two events:

- 400 (Engine state is changed from None to Available)
- 403 (Engine state is changed from Available to Stopped)

Inside the third file, you can find all process which were matched (script execution and script termination:

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/15.PNG?raw=true)

All three files are saved to the provided location:

![alt text](https://github.com/gajos112/PowerShell-Timeliner/blob/main/images/14.PNG?raw=true)
