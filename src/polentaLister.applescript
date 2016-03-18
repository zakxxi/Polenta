(****************************
polentaLister v1.1
by Adrien Revel 2015
****************************)

set baseFolder to choose folder with prompt "Select base folder" default location (path to desktop folder) as alias
set destFolder to choose folder with prompt "Select destination of report file" default location (path to desktop folder) as alias

set baseFolderX to POSIX path of baseFolder
set baseFolderXX to quoted form of baseFolderX

set destFolderX to POSIX path of destFolder
set destFolderXX to quoted form of destFolderX

(*
CREATE DATE STRING
*)

set {year:y, month:m, day:d, hours:h, minutes:mm} to (current date)
set m to m as integer

if m < 10 then set m to "0" & (m as string)
if d < 10 then set d to "0" & (d as string)
if h < 10 then set h to "0" & (d as string)
if mm < 10 then set mm to "0" & (d as string)

set dateTag to ((((y as string) & m as string) & d as string) & "-" & h as string) & "H" & mm as string

set outputFileName to "POLENTA-REPORT-" & dateTag & ".csv"

set cmd_listKeywords to "/usr/local/bin/exiftool -keywords -r -f -ext JPG -i 'Trash Capture' " & baseFolderXX & " > " & destFolderX & "keywords-list.txt"
set cmd_convertKeywordsOdd to "awk 'NR % 2 == 0' " & destFolderX & "keywords-list.txt > " & destFolderX & "odd.csv"
set cmd_convertKeywordsEven to "awk 'NR % 2 == 1' " & destFolderX & "keywords-list.txt > " & destFolderX & "even.csv"
set cmd_pasteKeywords to "paste -d ',' " & destFolderX & "even.csv " & destFolderX & "odd.csv > " & destFolderX & "total.csv"
set cmd_cleanKeywords1 to "sed 's/======== //g' " & destFolderX & "total.csv > " & destFolderX & "total2.csv"
set cmd_cleanKeywords2 to "sed 's/Keywords                        ://g'  " & destFolderX & "total2.csv >  " & destFolderX & "total3.csv"
set cmd_cleanKeywords3 to "sed 's/CO_//g'  " & destFolderX & "total3.csv >  " & destFolderX & "total4.csv"
set cmd_cleanKeywords4 to "sed 's/, /;/g' " & destFolderX & "total4.csv > " & destFolderX & outputFileName
set cmd_cleanupFiles to "rm " & destFolderX & "keywords-list.txt " & destFolderX & "odd.csv " & destFolderX & "even.csv " & destFolderX & "total.csv " & destFolderX & "total2.csv " & destFolderX & "total3.csv " & destFolderX & "total4.csv"

do shell script cmd_listKeywords
do shell script cmd_convertKeywordsOdd
do shell script cmd_convertKeywordsEven
do shell script cmd_pasteKeywords
do shell script cmd_cleanKeywords1
do shell script cmd_cleanKeywords2
do shell script cmd_cleanKeywords3
do shell script cmd_cleanKeywords4
do shell script cmd_cleanupFiles

display dialog outputFileName & " GENERATED!" buttons {"OK!"} default button 1 with icon caution