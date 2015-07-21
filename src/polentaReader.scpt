(****************************
polentaReader v0.2
by Adrien Revel 2015
****************************)(*
Set properties
*)property polWindowName : "polentaReader v0.1"--global polBaseFolder--global polDateFolder--global polPhotographerFolder--global polBuyerFolder(*
Set defaults folders
*)set scriptDirectory to (path to me) -- folder of scripttell application "Finder" to set polDirectory to POSIX path of (container of (container of scriptDirectory) as alias) -- folder of polentaset polPrefsDirectory to polDirectory & "prefs/" -- folder of preferences(*
Read preferences files
*)set polBuyersPrefs to read polPrefsDirectory & "polBuyers.txt" using delimiter linefeed -- create a list, after linebreakset polClippingTypesPrefs to read polPrefsDirectory & "polClippingTypes.txt" using delimiter linefeed -- create a list, after linebreak(*
Set base and dest folders
*)set baseFolder to (choose folder with prompt "Dossier de base")set destFolder to (choose folder with prompt "Dossier de destination")(*
Copy all jpg in a _batch folder
*)tell application "Finder"	with timeout of 3600 seconds				set batchFolder to make new folder at destFolder with properties {name:"_BATCH"}				repeat with eachFile in (every file of (entire contents of folder baseFolder) whose name extension is "jpg") as alias list			duplicate eachFile to batchFolder		end repeat	end timeoutend tell(*
DETOUR FOLDERS
*)tell application "Finder"	set outputFolder to make new folder at destFolder with properties {name:"_OUTPUT"}	repeat with i in polClippingTypesPrefs		make new folder at outputFolder with properties {name:"DE_" & i}	end repeatend tell(*
READ TAGS FOLDERS
*)tell application "Finder" to set outputFolderList to name of every folder of entire contents of outputFolderrepeat with i in batchFolder	-- display dialog (i as text)		set pathToImage to i as alias		set detourTag to read_tags(pathToImage)		repeat with j in outputFolderList				if contents of j = detourTag then			set endFolder to ((outputFolder as string) & j) as alias			--	display dialog ("WIN" & "     " & POSIXpathToImage & "     " & endFolder)			-- do shell script "mv " & POSIXpathToImage & " " & endFolder			tell application "Finder" to duplicate pathToImage to endFolder					end if	end repeatend repeat(*
Assemble patch folder
*)tell application "Finder"	if (count items) of (folder ((outputFolder as string) & "DE_PATCH ENVERS")) is greater than 0 then		move (every file of entire contents of folder ((outputFolder as string) & "DE_PATCH ENVERS")) to (folder ((outputFolder as string) & "DE_PATCH ENDROIT"))		delete folder ((outputFolder as string) & "DE_PATCH ENVERS")		set name of folder ((outputFolder as string) & "DE_PATCH ENDROIT") to "DE_PATCH"	end ifend tell(*
Delete empty folders
*)tell application "Finder"	repeat with this_folder in (get folders of outputFolder)		if (count items of this_folder) is 0 then delete this_folder	end repeatend tell(*
Delete batch folders
*)tell application "Finder"	delete batchFolderend tell(*
Move outputs folder
*)tell application "Finder"	repeat with this_folder in (get folders of outputFolder)		move this_folder to destFolder	end repeatend tell(*
Delete output folder
*)tell application "Finder"	delete outputFolderend tell(*
Display message
*)(*
Empty the trash
*)(*
Utilities functions
*)on read_tags(pathToImage)		set POSIXpathToImage to POSIX path of pathToImage		set tagsList to do shell script "exiftool -subject " & "'" & POSIXpathToImage & "'"	set cleanTags to replace_chars(tagsList, "Subject                         : ", "")	set cleanTagsList to split(cleanTags, ", ")		set detourTag to item 7 of cleanTagsList	--set buyerTag to item 3 of cleanTagsList	--display dialog buyerTag & "  " & detourTag buttons {"NEXT"} default button 1 with icon note		return detourTag	end read_tagson replace_chars(this_text, search_string, replacement_string)	set AppleScript's text item delimiters to the search_string	set the item_list to every text item of this_text	set AppleScript's text item delimiters to the replacement_string	set this_text to the item_list as string	set AppleScript's text item delimiters to ""	return this_textend replace_charson split(someText, delimiter)	set AppleScript's text item delimiters to delimiter	set someText to someText's text items	set AppleScript's text item delimiters to {""} --> restore delimiters to default value	return someTextend split