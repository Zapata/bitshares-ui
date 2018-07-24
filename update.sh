#! /bin/bash

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

update_master() {
    git checkout master
    git pull official $latest_release --no-edit
    git tag "$latest_release-zapata"
    docker build -t registry.dex.trading/bitshares-ui:$latest_release-zapata . 
    docker push registry.dex.trading/bitshares-ui:$latest_release-zapata
}

update_branch() {
    git checkout $1
    git merge master --no-edit
    git tag "$latest_release-$1"
    docker build -t registry.dex.trading/bitshares-ui:$latest_release-$1 . 
    docker push registry.dex.trading/bitshares-ui:$latest_release-$1
}



git remote -v | grep -q official
if [ $? -ne 0 ]; then
    echo "Add official bitshares-ui remote git"
    git remote add official https://github.com/bitshares/bitshares-ui.git
fi

git fetch --all

latest_release=$(get_latest_release "bitshares/bitshares-ui")
echo "Latest release: $latest_release"

update_master

update_branch bnp
update_branch xbto

git push origin --all
