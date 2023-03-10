export ASDF_DIR="/opt/asdf-vm"

if [ -n "$BASH_VERSION" ]; then
	# shellcheck disable=SC1091
	. "${ASDF_DIR}/opt/asdf/asdf.sh"
	# shellcheck disable=SC1091
	. "${ASDF_DIR}/completions/asdf.bash"
fi
