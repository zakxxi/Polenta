(****************************
polentaReader v0.3
by Adrien Revel 2015
****************************)

(*
Set defaults folders
*)
set scriptDirectory to (path to me) -- folder of script
tell application "Finder" to set polDirectory to POSIX path of (container of (container of scriptDirectory) as alias) -- folder of polenta
set polPrefsDirectory to polDirectory & "prefs/" -- folder of preferences

-- Choose work folders
set baseFolder to choose folder with prompt "Select base folder" default location (path to desktop folder) as alias
set destFolder to choose folder with prompt "Select dest folder" default location (path to desktop folder) as alias

-- Debug work folders
--set baseFolder to "Data HD:_BRICE BIG STUFF:"
--set destFolder to "Mac HD:Users:zak:Desktop:OUT:"

-- Convert to POSIX and quoted POSIX path
set polPrefsDirectoryX to POSIX path of polPrefsDirectory
set polPrefsDirectoryXX to quoted form of polPrefsDirectoryX

set baseFolderX to POSIX path of baseFolder
set baseFolderXX to quoted form of baseFolderX

set destFolderX to POSIX path of destFolder
set destFolderXX to quoted form of destFolderX

-- Create path of work folders
set batchFolderX to destFolderX & "_BATCH"
set batchFolderXX to quoted form of batchFolderX

set notagFolderX to destFolderX & "_NOTAG"
set notagFolderXX to quoted form of notagFolderX

set outputFolderX to destFolderX & "_OUTPUT"
set outputFolderXX to quoted form of outputFolderX

-- Create work folder
-- mkdir '/Users/zak/Desktop/OUT/_BATCH' '/Users/zak/Desktop/OUT/_NOTAG' '/Users/zak/Desktop/OUT/_OUTPUT'
set cmd_createWorkFolders to "mkdir " & batchFolderXX & " " & notagFolderXX & " " & outputFolderXX

-- Define the path to look
--set findPath to "*/Output/*"

set findPath to (choose from list {"*/Output/*", "*"} with prompt "Choose the find pattern" default items {"*/Output/*"}) as string

-- Run shell script to find all jpg in baseFolder and copy to destFolder
-- find '/Volumes/Data HD/_BRICE BIG STUFF/' -name '*.jpg' -path '*/Output/*' -exec cp {} '/Users/zak/Desktop/OUT/' \;
set cmd_findJPGcopy to "find " & baseFolderXX & " -name '*.jpg' -path '" & findPath & "' -exec cp {} " & batchFolderXX & " \\;"

set nb_jpg_original to do shell script ("find " & baseFolderXX & " -name '*.jpg' -path '" & findPath & "' | wc -l") -- count number of image to process

do shell script cmd_createWorkFolders
do shell script cmd_findJPGcopy

-- Check for images without tags
-- mdfind -onlyin . 'kMDItemKeywords != "*"'
set cmd_isolateNoTag to "mdfind -onlyin " & batchFolderXX & " 'kMDItemKeywords != \"*\"' | while read f; do mv \"$f\" " & notagFolderXX & "; done "
do shell script cmd_isolateNoTag
delay 10

set nb_jpg_batch to do shell script ("find " & batchFolderXX & " -name '*.jpg' -path '" & findPath & "' | wc -l")
set nb_jpg_notag to do shell script ("find " & notagFolderXX & " -name '*.jpg' -path '" & findPath & "' | wc -l")


(*
DETOUR FOLDERS
*)
-- path to polClippingTypes.txt
--set polClippingTypes to quoted form of (polPrefsDirectoryX & "polClippingTypes.txt")

-- create detour folders
--set cmd_createClippingFolders to "cd " & outputFolderX & " && while read -r f; do mkdir -p DE_\"$f\";done < " & polClippingTypes

--do shell script cmd_createClippingFolders


(*
++++++++++
AS ZONE
++++++++++
*)

set baseFolder to POSIX file (get batchFolderX) as alias
set destFolder to POSIX file (get outputFolderX) as alias

(*
Set defaults folders
*)
set scriptDirectory to (path to me) -- folder of script
tell application "Finder" to set polDirectory to POSIX path of (container of (container of scriptDirectory) as alias) -- folder of polenta
set polPrefsDirectory to polDirectory & "prefs/" -- folder of preferences

(*
Read preferences files
*)
--set polBuyersPrefs to read polPrefsDirectory & "polBuyers.txt" using delimiter linefeed -- create a list, after linebreak
set polClippingTypesPrefs to read polPrefsDirectory & "polClippingTypes.txt" using delimiter linefeed -- create a list, after linebreak


(*
DETOUR FOLDERS
*)
tell application "Finder"
	repeat with i in polClippingTypesPrefs
		make new folder at destFolder with properties {name:"DE_" & i}
	end repeat
end tell


(*
READ TAGS FOLDERS
*)
tell application "Finder" to set outputFolderList to name of every folder of entire contents of destFolder
tell application "Finder" to set fileList to every item of baseFolder
repeat with i in fileList
	-- display dialog (i as text)
	
	set pathToImage to i as alias
	
	set detourTag to read_tags(pathToImage)
	
	repeat with j in outputFolderList
		
		if contents of j = detourTag then
			set endFolder to ((destFolder as string) & j) as alias
			--	display dialog ("WIN" & "     " & POSIXpathToImage & "     " & endFolder)
			-- do shell script "mv " & POSIXpathToImage & " " & endFolder
			tell application "Finder" to move pathToImage to endFolder
			
		end if
	end repeat
end repeat

(*
Assemble patch folder
*)
tell application "Finder"
	if (count items) of (folder ((destFolder as string) & "DE_PATCH ENVERS")) is greater than 0 then
		move (every file of entire contents of folder ((destFolder as string) & "DE_PATCH ENVERS")) to (folder ((destFolder as string) & "DE_PATCH ENDROIT"))
		delete folder ((destFolder as string) & "DE_PATCH ENVERS")
		set name of folder ((destFolder as string) & "DE_PATCH ENDROIT") to "DE_PATCH"
	end if
end tell

(*
Delete empty folders
*)
tell application "Finder"
	repeat with i in (get folders of destFolder)
		if (count items of i) is 0 then delete i
	end repeat
end tell

set nb_jpg_output to do shell script ("find " & outputFolderXX & " -name '*.jpg' -path '" & findPath & "' | wc -l")



(*
Display message
*)
display dialog "+++ YOU WIN! +++ PERFECT! +++

Original images : 	" & nb_jpg_original & "
Batch images : 	" & nb_jpg_batch & "
Notag images : 	" & nb_jpg_notag & "
Output images : 	" & nb_jpg_output buttons {"PERFECT!"} default button 1 with title "polentaFilter" with icon caution

(*
Empty the trash
*)

(*
Utilities functions
*)

on read_tags(pathToImage)
	
	set POSIXpathToImage to POSIX path of pathToImage
	
	set tagsList to do shell script "exiftool -subject " & "'" & POSIXpathToImage & "'"
	set cleanTags to replace_chars(tagsList, "Subject                         : ", "")
	set cleanTagsList to split(cleanTags, ", ")
	
	set detourTag to item 7 of cleanTagsList
	--set buyerTag to item 3 of cleanTagsList
	--display dialog buyerTag & "  " & detourTag buttons {"NEXT"} default button 1 with icon note
	
	return detourTag
	
end read_tags

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

on split(someText, delimiter)
	set AppleScript's text item delimiters to delimiter
	set someText to someText's text items
	set AppleScript's text item delimiters to {""} --> restore delimiters to default value
	return someText
end split



