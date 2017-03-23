#Created to skim event logs with more then 50 servers checking event 
#logs server by server takes to long, so this dumps all warnings 
#and erros into a text file. i then sorte the files by size 
#and tackle the most chatty server first. 
#Creation date : 07-30-2016
#Creator: Alix N Hoover




# Load the Microsoft Active Directory Module
Import-Module ActiveDirectory


#Variables to change
$DCServer = "ntpri"
$DomainName = "LYCO"
$DomainControlerOU = "OU=servers, DC=LYCO,DC=org"
$DomainServerOU = "OU=Domain Controllers, DC=LYCO,DC=org"




#get all of todays info
$today = get-date
$ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition
$rundate = ([datetime]$today).tostring("MM_dd_yyyy")
$year = ([datetime]$today).tostring("yyyy")
$month = ([datetime]$today).tostring("MM")
$day = ([datetime]$today).tostring("dd")



# Set Directory Path
$Directory = $ScriptPath + "\reports\" + "\EventLogs\"+ $year + "\" + $month + "\" + $day + "\" + $DomainName



# Create directory if it doesn't exsist
if (!(Test-Path $Directory))
{
New-Item $directory -type directory
}


#Create the array of Servers
$ServerOU =@()
$ServerOU = get-adcomputer -server $DCServer -searchbase $DomainControlerOU -filter * | ForEach-Object {$_.Name}
$ServerOU += get-adcomputer -server $DCServer -searchbase $DomainServerOU -filter * | ForEach-Object {$_.Name}


#For Loop time!
foreach ($Server in $ServerOU){
  if (test-Connection -ComputerName $Server -Count 2 -Quiet ) 
  {  
		
        $filname2 = $Server +"_Application.txt"
        $filname3 = $Server +"_System.txt"
        Write-Host "Pulling logs for " $Server
       
		Get-EventLog Application -ComputerName $Server -After (Get-Date).AddDays(-1) | Where-Object {$_.EntryType -eq "Error"-or $_.EntryType -eq "Warning"} | format-list > $Directory\$filname2 
        Get-EventLog system -ComputerName $Server -After (Get-Date).AddDays(-1) | Where-Object {$_.EntryType -eq "Error"-or $_.EntryType -eq "Warning"} | format-list > $Directory\$filname3

        
        
  } else 
          { Write-Warning "$Server seems dead not pinging" 
          }     



                            }
                            
                           
