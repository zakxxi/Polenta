set baseFolder to (choose folder with prompt "Choose folder to process")

set baseFolderX to POSIX path of baseFolder
set baseFolderXX to quoted form of baseFolderX

set cmd_listKeywords to "exiftool " & baseFolderX & "* -keywords -f > " & baseFolderX & "keywords-list.txt"
set cmd_convertKeywordsOdd to "awk 'NR % 2 == 0' " & baseFolderX & "keywords-list.txt > " & baseFolderX & "odd.csv"
set cmd_convertKeywordsEven to "awk 'NR % 2 == 1' " & baseFolderX & "keywords-list.txt > " & baseFolderX & "even.csv"
set cmd_pasteKeywords to "paste -d ',' " & baseFolderX & "even.csv " & baseFolderX & "odd.csv > " & baseFolderX & "total.csv"
set cmd_cleanKeywords1 to "sed 's/======== //g' " & baseFolderX & "total.csv > " & baseFolderX & "total2.csv"
set cmd_cleanKeywords2 to "sed 's/Keywords                        ://g'  " & baseFolderX & "total2.csv >  " & baseFolderX & "total3.csv"
set cmd_cleanKeywords3 to "sed 's/CO_//g'  " & baseFolderX & "total3.csv >  " & baseFolderX & "total4.csv"
set cmd_cleanKeywords4 to "sed 's/, /;/g' " & baseFolderX & "total4.csv > " & baseFolderX & "_OUTPUT.csv "
set cmd_cleanupFiles to "rm " & baseFolderX & "keywords-list.txt " & baseFolderX & "odd.csv " & baseFolderX & "even.csv " & baseFolderX & "total.csv " & baseFolderX & "total2.csv " & baseFolderX & "total3.csv " & baseFolderX & "total4.csv"

do shell script cmd_listKeywords
do shell script cmd_convertKeywordsOdd
do shell script cmd_convertKeywordsEven
do shell script cmd_pasteKeywords
do shell script cmd_cleanKeywords1
do shell script cmd_cleanKeywords2
do shell script cmd_cleanKeywords3
do shell script cmd_cleanKeywords4
do shell script cmd_cleanupFiles

display dialog "DONE!" buttons {"OKAY"} default button 1 with icon caution