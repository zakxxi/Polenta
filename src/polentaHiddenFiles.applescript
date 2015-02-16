(****************************
polentaHiddenFiles v0.1
by Adrien Revel 2015
****************************)

(*
Set properties
*)
property polWindowName : "polentaHiddenFiles v0.1"
set polChoice to button returned of (display dialog "Afficher ou masquer les fichiers cachés ?" buttons {"Masquer", "Afficher"} with title polWindowName with icon note)
set osMinorVersion to system attribute "sys2" -- check system "minor" version

if (osMinorVersion ≥ 9) then -- check for OS 10.9 & 10.10
	if (polChoice = "Afficher") then do shell script "defaults write com.apple.finder AppleShowAllFiles TRUE; killall Finder"
	if (polChoice = "Masquer") then do shell script "defaults write com.apple.finder AppleShowAllFiles FALSE; killall Finder"
	
else if (osMinorVersion ≤ 9 and osMinorVersion ≥ 6) then -- check for OS 10.6 to 10.8
	if (polChoice = "Afficher") then
		
		do shell script "defaults write com.apple.Finder AppleShowAllFiles TRUE"
		do shell script "killall Finder"
	end if
	
	if (polChoice = "Masquer") then
		do shell script "defaults write com.apple.Finder AppleShowAllFiles FALSE"
		do shell script "killall Finder"
	end if
	
else
	error
end if
