#!/usr/bin/env bats

@test "asdf is in PATH" {
	command -v asdf
}

@test "asdf plugins are installed" {
	run asdf plugin list
	[[ "$output" = *golang* ]]
	[[ "$output" = *python* ]]
	[[ "$output" = *terraform* ]]
}
