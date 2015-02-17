(****************************
polentaTagger v0.5
by Adrien Revel 2015
****************************)

(*
Set properties
*)
property polWindowName : "polentaTagger v0.5"
property polOkButtonName : "Continuer"
property polCancelButtonName : "Annuler"

on run argv
	(*
Set defaults folders
*)
	set scriptDirectory to (path to me) -- folder of script
	tell application "Finder" to set polDirectory to POSIX path of (container of (container of scriptDirectory) as alias) -- folder of polenta
	set polPrefsDirectory to polDirectory & "prefs/" -- folder of preferences
	
	(*
Read preferences files
*)
	set polSessionPrefs to read polPrefsDirectory & "polSession.txt" as string
	set polPhotographerPrefs to read polPrefsDirectory & "polPhotographer.txt" as string
	set polBuyersPrefs to read polPrefsDirectory & "polBuyers.txt" using delimiter linefeed -- create a list, after linebreak
	set polViewsPrefs to read polPrefsDirectory & "polViews.txt" using delimiter linefeed -- create a list, after linebreak
	set polClippingTypesPrefs to read polPrefsDirectory & "polClippingTypes.txt" using delimiter linefeed -- create a list, after linebreak
	
	(*
Set selected image in C1
*)
	set selectedImage to (item 1 of item 1 of argv) -- selected image in C1
	set polImagePath to POSIX file selectedImage as alias -- path to selected image in C1
	
	(*
Set path, name, extensions of image and folders
*)
	tell application "Finder"
		set polImageFile to file polImagePath -- original file of raw image
		set polImageOriginalName to (name of polImageFile) -- get the original filename
		set polImageFileExtension to (name extension of polImageFile) -- get the extension of filename
		if polImageFileExtension is not "" then set polImageOriginalName to text 1 thru -((count polImageFileExtension) + 2) of polImageOriginalName -- extract the name part without extension
		set polCaptureDirectory to POSIX path of ((container of polImageFile) as alias) -- path to Capture Folder
		set polSessionDirectory to (container of (container of polImageFile) as alias) -- path to Session Folder
		set polBuyerName to name of folder polSessionDirectory
	end tell
	
	(*
Enter barcode and check-it
*)
	set authorizedCharacters to {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " "}
	set polBarcode to ""
	set polBadBarcode to false
	
	repeat while (length of polBarcode) ­ 10 or (polBadBarcode is true) -- check if barcode length
		set polBarcode to text returned of (display dialog "Scan du codebarre" default answer "" buttons {polCancelButtonName, polOkButtonName} default button 2 cancel button 1 with title polWindowName with icon note)
		
		set testedCharacters to characters of polBarcode as text -- test for bads characters
		
		repeat with i from 1 to (length of testedCharacters)
			set theTestedCharacter to character i of testedCharacters
			if theTestedCharacter is not in authorizedCharacters then
				set polBadBarcode to true
			else
				set polBadBarcode to false
			end if
		end repeat
		
		if polBadBarcode is false then set polBarcode to (do shell script "echo \"" & polBarcode & "\" | sed 's/ /_/g'") -- replace space with underscore
		
		if (((length of polBarcode) ­ 10) or polBadBarcode is true) then
			display dialog "Codebarre non valide " buttons {"Re-saisir"} default button 1 with title "Alerte" with icon caution
		end if
	end repeat
	
	(*
Set obligatory tags
*)
	set polView to (choose from list polViewsPrefs with title polWindowName with prompt "Point de vue" OK button name polOkButtonName cancel button name polCancelButtonName)
	set polClippingType to (choose from list polClippingTypesPrefs with title polWindowName with prompt "Type de detourage" OK button name polOkButtonName cancel button name polCancelButtonName)
	
	(*
Set optional tags
*)
	set polRetouch to text returned of (display dialog "Annotation retouche " default answer "" buttons {polCancelButtonName, polOkButtonName} default button 2 cancel button 1 with title polWindowName with icon note)
	set polKit to (choose from list {"KIT-1", "KIT-2", "KIT-3", "KIT-4", "KIT-5", "KIT-6", "KIT-7", "KIT-8"} with title polWindowName with prompt "Fait partie d'un KIT" OK button name polOkButtonName cancel button name polCancelButtonName with empty selection allowed)
	
	(*
Generate tags and filename
*)
	set polImageNewName to polBarcode & "_" & polView -- generate base new name of image
	
	set polSessionTag to "SE_" & polSessionPrefs
	set polBuyerTag to "AC_" & polBuyerName
	set polPhotographerTag to "PH_" & polPhotographerPrefs
	set polBarcodeTag to "CO_" & polBarcode
	set polViewTag to "VU_" & polView
	
	if ((polClippingType as string) = "PATCH ENVERS") then
		set polClippingTag to "DE_" & polClippingType
		set polImageNewName to polImageNewName & "-" & "PATCH" -- adding Kit to new name of image
	else
		set polClippingTag to "DE_" & polClippingType
	end if
	
	if polKit ­ {} then
		set polKitTag to "KI_" & polKit
		set polImageNewName to polImageNewName & "-" & polKit -- adding Kit to new name of image
	else
		set polKitTag to ""
	end if
	
	if polRetouch ­ "" then
		set polRetouchTag to "RE_" & polRetouch
		set polImageNewName to polImageNewName & "[" & polRetouch & "]" -- adding [Retouch] to new name of image
	else
		set polRetouchTag to ""
	end if
	
	(*
Set  and display confirm dialog message
*)
	set polRecapMessage to "
Session : " & polSessionPrefs & "
Acheteur : " & polBuyerName & "
Photographe : " & polPhotographerPrefs & "
Codebarre : " & polBarcode & "
Point de vue : " & polView & "
Detourage : " & polClippingType & "
Retouche : " & polRetouch & "
Kit : " & polKit
	
	display dialog polRecapMessage buttons {"Annuler", "TAG!"} default button 2 cancel button 1 with title polWindowName with icon stop
	
	(*
Rename the file
*)
	set polImageNewNameWithExtension to polImageNewName & "." & polImageFileExtension -- re-add file extension
	tell application "Finder" to set the name of polImageFile to polImageNewNameWithExtension -- rename raw image
	
	(*
Tag the file
*)
	set polPathToXMP to polCaptureDirectory & polImageNewName & ".xmp"
	set polTagList to polSessionTag & "," & polBuyerTag & "," & polPhotographerTag & "," & polBarcodeTag & "," & polViewTag & "," & polClippingTag & "," & "," & "," & polKitTag & polRetouchTag -- generate the taglist comma separated
	do shell script "/usr/bin/exiftool -overwrite_original -subject=" & quoted form of polTagList & " " & quoted form of polPathToXMP -- need to check exiftool location
	
	
	(*
Remove the old XMP
*)
	tell application "Finder" to delete ((POSIX file (polCaptureDirectory & polImageOriginalName & ".xmp")) as alias)
	
	
	
	
	(*
Process the image
*)
	
end run