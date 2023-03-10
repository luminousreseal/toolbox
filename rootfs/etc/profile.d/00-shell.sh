# vi key-binding prompt navigation
set -o vi

# default editor
if type vim &>/dev/null; then
	EDITOR="vim"
else
	EDITOR="vi"
fi

export EDITOR
