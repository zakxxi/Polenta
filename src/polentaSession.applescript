(****************************
polentaSession v1.1
by Adrien Revel 2015
****************************)

(*
Set properties
*)
property polWindowName : "polentaSession v1.1"
global polBaseFolder
global polDateFolder
global polPhotographerFolder
global polBuyerFolder

(*
Set defaults folders
*)
set scriptDirectory to (path to me) -- folder of script
tell application "Finder" to set polDirectory to POSIX path of (container of (container of scriptDirectory) as alias) -- folder of polenta
set polPrefsDirectory to polDirectory & "prefs/" -- folder of preferences

(*
Read preferences files
*)
set polPhotographerPrefs to read polPrefsDirectory & "polPhotographer.txt" as string
set polBuyersPrefs to read polPrefsDirectory & "polBuyers.txt" using delimiter linefeed -- create a list, after linebreak

(*
Set the date preferences files
*)
-- Check the current date
set polYear to year of (current date)
set polMonth to month of (current date) as integer
set polDay to day of (current date) as integer

-- Add 0 berfore day or month < 10
if (polMonth < 10) then set polMonth to ("0" & (polMonth as string))
if (polDay < 10) then set polDay to ("0" & (polDay as string))

-- Set the folder name
set polDateFolderName to (polYear & polMonth & polDay) as string

(*
Choose default folder
*)
set polBaseFolder to (choose folder with prompt "Choisir le dossier de travail : SESSION/WORK")

(*
Set Date folder
*)
set polDateFolder to (polBaseFolder as string) & (polDateFolderName as string)

(*
Set Photographer folder
*)
set polPhotographerFolder to (polDateFolder as string) & ":" & (polPhotographerPrefs as string)

(*
Choose a buyer
*)
set polBuyer to (choose from list polBuyersPrefs with title polWindowName with prompt "Choisir l'acheteur.")
set polBuyerFolder to (polPhotographerFolder as string) & ":" & (polBuyer as string)

(*
Create or not the session
*)
tell application "Finder"
	if exists polDateFolder then
		log "polDateFolder exists"
		if exists polPhotographerFolder then
			log "polPhotographerFolder exists"
			if exists polBuyerFolder then
				log "polBuyerFolder exists"
				display dialog "La session existe deja." buttons {"OK"} default button 1 with title polWindowName with icon stop giving up after 5
			else
				log "polBuyerFolder doesn't exists"
				
				tell application "Capture One"
					set posixPath to POSIX path of polPhotographerFolder
					log posixPath
					set newSession to make new document with properties {name:polBuyer, path:posixPath}
					activate newSession
				end tell
				
			end if
		else
			log "polPhotographerFolder doesn't exists"
			make new folder at polDateFolder with properties {name:polPhotographerPrefs}
			
			tell application "Capture One"
				set posixPath to POSIX path of polPhotographerFolder
				log posixPath
				set newSession to make new document with properties {name:polBuyer, path:posixPath}
				activate newSession
			end tell
			
		end if
		
	else
		log "polDateFolder doesn't exists"
		make new folder at polBaseFolder with properties {name:polDateFolderName}
		make new folder at polDateFolder with properties {name:polPhotographerPrefs}
		
		tell application "Capture One"
			set posixPath to POSIX path of polPhotographerFolder
			log posixPath
			set newSession to make new document with properties {name:polBuyer, path:posixPath}
			activate newSession
		end tell
	end if
	
end tell