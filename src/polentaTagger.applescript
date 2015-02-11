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
Set obligatory tags
*)
set polCodebar to text returned of (display dialog "Scan du codebarre" default answer "" buttons {polCancelButtonName, polOkButtonName} default button 2 cancel button 1 with title polWindowName with icon note)
set polView to (choose from list polViewsPrefs with title polWindowName with prompt "Point de vue" OK button name polOkButtonName cancel button name polCancelButtonName)
set polClippingFolder to (choose from list polClippingFoldersPrefs with title polWindowName with prompt "Point de vue" OK button name polOkButtonName cancel button name polCancelButtonName)

(*
Set optional tags
*)
set polRetouch to text returned of (display dialog "Annotation retouche " default answer "" buttons {polCancelButtonName, polOkButtonName} default button 2 cancel button 1 with title polWindowName with icon note)
set polKit to (choose from list {"KIT 1", "KIT 2", "KIT 3"} with title polWindowName with prompt "Fait partie d'un KIT" OK button name polOkButtonName cancel button name polCancelButtonName with empty selection allowed)

(*
Set  confirm dialog message
*)
set polRecapMessage to "
SESSION : " & polSessionPrefs & "
ACHETEUR : " & "TOTO" & "
PHOTOGRAPHE : " & polPhotographerPrefs & "
CODEBARRE : " & polCodebar & "
POINT DE VUE : " & polView & "
RETOUCHE : " & polRetouch & "
KIT : " & polKit

display dialog polRecapMessage buttons {"Annuler", "DEVELOPPER"} default button 2 cancel button 1 with title polWindowName with icon stop