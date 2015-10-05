(****************************
polentaInstaller 1.0
by Adrien Revel 2015
****************************)
(*
Set properties
*)
property polWindowName : "polentaInstaller v1.0"

(*
Set defaults files folders
*)
set scriptDirectory to (path to me) -- folder of script
tell application "Finder" to set polDirectory to (container of (container of scriptDirectory) as alias) -- folder of polenta
set polExeDirectory to polDirectory & "exe:" -- folder of executables scripts

set captureOneScriptsFolder to ((path to home folder as string) & "Library:Scripts:Capture One Scripts" as alias)
set polentaScriptsFolder to ((captureOneScriptsFolder as string) & "POLENTA")

set polentaTagger to (polExeDirectory & "polentaTagger.app" as string as alias)
set polentaSession to (polExeDirectory & "polentaSession.app" as string as alias)
--set polentaHiddenFiles to (polExeDirectory & "polentaHiddenFiles.app" as string as alias)

set polInstall to button returned of (display dialog "Voulez-vous ajouter ou supprimer les scripts Polenta du menu \"Scripts\" de Capture One ?" buttons {"Supprimer", "Ajouter"} with title polWindowName with icon note)

if polInstall = "Ajouter" then
	tell application "Finder"
		if exists polentaScriptsFolder then
			display dialog "Polenta est déjà installé dans Capture One." buttons {"OK"} default button 1 with title polWindowName with icon caution
		else
			make folder at captureOneScriptsFolder with properties {name:"POLENTA"}
			make alias to polentaTagger at polentaScriptsFolder
			make alias to polentaSession at polentaScriptsFolder
			--make alias to polentaHiddenFiles at polentaScriptsFolder
			display dialog "Polenta a été ajouté dans Capture One." buttons {"OK"} default button 1 with title polWindowName with icon caution
			
		end if
	end tell
else
	
	tell application "Finder"
		if exists polentaScriptsFolder then
			delete polentaScriptsFolder
			display dialog "Polenta a été supprimé dans Capture One." buttons {"OK"} default button 1 with title polWindowName with icon caution
		else
			display dialog "Polenta n'est pas installé dans Capture One." buttons {"OK"} default button 1 with title polWindowName with icon caution
		end if
	end tell
	
end if

