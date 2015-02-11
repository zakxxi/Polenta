(****************************
polentaTagger v0.1
by Adrien Revel 2015
****************************)

(*
Set properties
*)
property polWindowName : "polentaTagger v0.1"
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
	set polClippingFoldersPrefs to read polPrefsDirectory & "polClippingFolders.txt" using delimiter linefeed -- create a list, after linebreak
	
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
Set obligatory tags
*)
	set polCodebar to text returned of (display dialog "Scan du codebarre" default answer "" buttons {polCancelButtonName, polOkButtonName} default button 2 cancel button 1 with title polWindowName with icon note)
	
	set polView to (choose from list polViewsPrefs with title polWindowName with prompt "Point de vue" OK button name polOkButtonName cancel button name polCancelButtonName)
	set polClippingFolder to (choose from list polClippingFoldersPrefs with title polWindowName with prompt "Dossier de détourage" OK button name polOkButtonName cancel button name polCancelButtonName)
	
	(*
Set optional tags
*)
	set polRetouch to text returned of (display dialog "Annotation retouche " default answer "" buttons {polCancelButtonName, polOkButtonName} default button 2 cancel button 1 with title polWindowName with icon note)
	set polKit to (choose from list {"KIT 1", "KIT 2", "KIT 3"} with title polWindowName with prompt "Fait partie d'un KIT" OK button name polOkButtonName cancel button name polCancelButtonName with empty selection allowed)
	
	(*
Set  confirm dialog message
*)
	set polRecapMessage to "
Session : " & polSessionPrefs & "
Acheteur : " & polBuyerName & "
Photographe : " & polPhotographerPrefs & "
Codebarre : " & polCodebar & "
Point de vue : " & polView & "
Détourage : " & polClippingFolder & "
Retouche : " & polRetouch & "
Kit : " & polKit
	
	display dialog polRecapMessage buttons {"Annuler", "DEVELOPPER"} default button 2 cancel button 1 with title polWindowName with icon stop
	
	(*
Generate tags
*)
	set polSessionTag to "SE_" & polSessionPrefs
	set polBuyerTag to "AC_" & polBuyerName
	set polPhotographerTag to "PH_" & polPhotographerPrefs
	set polBarcodeTag to "CO_" & polCodebar
	set polViewTag to "VU_" & polView
	set polClippingTag to "DE_" & polClippingFolder
	set polRetouchTag to "RE_" & polRetouch
	set polKitTag to "KI_" & polKit
	
	(*
Rename the file
*)
	set polImageNewName to polCodebar & " _" & polView & " _" & polKit & "[" & polRetouch & "]" -- generate new name of image
	set polImageNewNameWithExtension to polImageNewName & "." & polImageFileExtension -- re-add file extension
	
	tell application "Finder" to set the name of polImageFile to polImageNewNameWithExtension -- rename raw image
	
	(*
Tag the file
*)
	set polPathToXMP to polCaptureDirectory & polImageNewName & ".xmp"
	set polTagList to polSessionTag & "," & polBuyerTag & "," & polPhotographerTag & "," & polBarcodeTag & "," & polViewTag & "," & polClippingTag & "," & polRetouchTag & "," & polKitTag -- generate the taglist comma separated
	
	do shell script "/usr/local/bin/exiftool -overwrite_original -subject=" & quoted form of polTagList & " " & quoted form of polPathToXMP
	
	(*
Remove the old XMP
*)
	tell application "Finder" to delete ((POSIX file (polCaptureDirectory & polImageOriginalName & ".xmp")) as alias)
	
	(*
Process the image
*)
	
end run