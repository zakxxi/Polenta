(****************************
polentaSandbox v0.1
by Adrien Revel 2015
****************************)
set authorizedCharacters to {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " "}
set polBarcode to ""

set polBadBarcode to false

repeat while (length of polBarcode) ­ 10
	set polBarcode to text returned of (display dialog "Enter a text" default answer "" with title "" with icon note)
	if (length of polBarcode) ­ 10 then display dialog "Codebarre non valide (­ de 10 caracteres) " buttons {"Re-saisir"} default button 1 with title "Alerte" with icon caution
end repeat

set testedCharacters to characters of polBarcode as text

repeat with i from 1 to (length of testedCharacters)
	set theTestedCharacter to character i of testedCharacters
	if theTestedCharacter is not in authorizedCharacters then
		set polBadBarcode to true
	end if
end repeat

if polBadBarcode is true then
	display dialog ("bad")
else
	set polBarcode to (do shell script "echo \"" & polBarcode & "\" | sed 's/ /_/g'") -- replace space with underscore
end if


