# git_merge_hook deletes local tracking branches that are no longer on remote that have been merged with a merge commit
function git_merge_hook() {
	git branch --merged | grep -E -v "(^\*|master|dev|main)" | xargs git branch -d 2>/dev/null
	git fetch -p
}

# git_authors displays all all commit authors in the repository
function git_authors() {
	git log --pretty="%an %ae%n%cn %ce" | sort | uniq
}

# git_purge purges a file or directory from the repository's history
function git_purge() {
	if [ -d "$1" ]; then
		RECURSIVE="-r"
	fi

	git filter-branch --force --indexer-filter "git rm ${RECURSIVE} --cached --ignore-unmatch ${1}" --prune-empty --tag-name-filter cat -- --all
}

# gitlocaconfig sets local repository config using global values
function git_local_config() {
	git config user.name "$(git config --get user.name)"
	git config user.email "$(git config --get user.email)"
}

# git_change_commit_author updates all commits with a specific email with a new email and name
function git_change_commit_author() {
	while getopts "e:fm:n:" opt; do
		case "$opt" in
		e)
			WRONG_EMAIL="$OPTARG"
			;;
		f)
			FORCE="--force"
			;;
		n)
			NEW_NAME="$OPTARG"
			;;
		m)
			NEW_EMAIL="$OPTARG"
			;;
		*)
			echo "unknown option: ${opt}"
			exit 1
			;;
		esac
	done

	FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch "$FORCE" --env-filter "
if [ \"\$GIT_COMMITTER_EMAIL\" = \"$WRONG_EMAIL\" ]
then
    export GIT_COMMITTER_NAME=\"$NEW_NAME\"
    export GIT_COMMITTER_EMAIL=\"$NEW_EMAIL\"
fi
if [ \"\$GIT_AUTHOR_EMAIL\" = \"$WRONG_EMAIL\" ]
then
    export GIT_AUTHOR_NAME=\"$NEW_NAME\"
    export GIT_AUTHOR_EMAIL=\"$NEW_EMAIL\"
fi
" --tag-name-filter cat -- --branches --tags
}
