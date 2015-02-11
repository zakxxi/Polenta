(****************************
polentaSandbox v0.1
by Adrien Revel 2015
****************************)
on run argv
	
	set barcode to text returned of (display dialog "Scan du code barre" default answer "" buttons {"Suivant…"} default button 1 with title "Codebarre" with icon note)
	
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
Rename the file
*)
	set polImageNewName to barcode & " POLENTA" -- generate new name of image
	set polImageNewNameWithExtension to polImageNewName & "." & polImageFileExtension -- re-add file extension
	
	tell application "Finder" to set the name of polImageFile to polImageNewNameWithExtension -- rename raw image
	
	(*
Tag the file
*)
	set polPathToXMP to polCaptureDirectory & polImageNewName & ".xmp"
	set polTagList to "Hello" & "," & "World" & "," & barcode
	do shell script "/usr/local/bin/exiftool -overwrite_original -subject=" & quoted form of polTagList & " " & quoted form of polPathToXMP
	
	(*
Remove the old XMP
*)
	tell application "Finder" to delete ((POSIX file (polCaptureDirectory & polImageOriginalName & ".xmp")) as alias)
	(*
Process the image
*)
	
end run