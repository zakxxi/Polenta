(****************************
polentaSandbox v0.1
by Adrien Revel 2015
****************************)

set inputText to ""

repeat while inputText ­ 10
	set inputText to text returned of (display dialog "Enter a text" default answer "" with title "" with icon note)
	display dialog "Texte non valide" buttons {"Re-saisir"} default button 1 with title "Alerte" with icon caution
end repeat


set inputText to (do shell script "echo \"" & inputText & "\" | sed 's/ /_/g'") -- relace space with underscore
display dialog (inputText)