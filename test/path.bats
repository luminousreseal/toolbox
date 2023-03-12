#!/usr/bin/env bats

function check_path() {
	for p in "$@"; do
		command -v "$p"
	done
}

@test "test npm packages are available in PATH" {
	check_path gatsby npm vue yarn
}

@test "test pip packages are available in PATH" {
	check_path ansible ansible-lint checkov scdl yt-dlp
}
