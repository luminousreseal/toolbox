NPM_PACKAGES="${HOME}/.npm-packages"

test -d "$NPM_PACKAGES" || mkdir -pv "$NPM_PACKAGES"

if [ -d "$NPM_PACKAGES" ]; then
	PATH="${NPM_PACKAGES}/bin:${PATH}"
fi

export NPM_PACKAGES PATH
