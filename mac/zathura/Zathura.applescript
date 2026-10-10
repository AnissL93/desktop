-- Zathura.app: lets Finder and `open` hand files to zathura (a command-line GTK app with no bundle).
-- build: bootstrap.sh step builds (osacompile into ~/Applications/Zathura.app); default for
-- .pdf/.epub/.mobi: step defaults (duti).
on open theFiles
	repeat with f in theFiles
		do shell script "/opt/homebrew/bin/zathura " & quoted form of POSIX path of f & " >/dev/null 2>&1 &"
	end repeat
end open

on run
	do shell script "/opt/homebrew/bin/zathura >/dev/null 2>&1 &"
end run
