#!/usr/bin/env bash

EXTENSIONS_FILE="${EXTENSIONS_FILE:-"/etc/codium-extensions.txt"}"

if [ -f "$EXTENSIONS_FILE" ]; then
	mapfile -t CODIUM_EXTENSIONS < <(grep -h -v '^#' "${EXTENSIONS_FILE}")
else
	CODIUM_EXTENSIONS=()
fi

while getopts "f" o; do
	case "$o" in
	f)
		FORCE="--force"
		;;
	*)
		break
		;;
	esac
done

if type codium &>/dev/null; then
	for ext in "${CODIUM_EXTENSIONS[@]}"; do
		codium "$FORCE" --install-extension "$ext"
	done
else
	echo "codium is not installed"
	exit 1
fi
