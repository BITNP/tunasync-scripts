#!/bin/bash
set -e
DEST=/mirror/_frontend
DEST_TMP=/mirror/_frontend_bak
# DEST_TMP should be on the same fs with DEST
GIT_URL=https://github.com/BITNP/bitnp-mirrors-web.git
GIT_PATH=/tmp/frontend-build
GIT_BRANCH=master
NPM_WD=${GIT_PATH}/themes/bitnp-mirror/src
HUGO_OUTPUT=${GIT_PATH}/public
HUGO_BASE=http://staging.mirrors.bitnp.net/

# rm -rf $GIT_PATH
git clone --branch $GIT_BRANCH --depth 1 $GIT_URL $GIT_PATH \
    || (cd $GIT_PATH ; git fetch origin; git reset --hard origin/${GIT_BRANCH})

# npm build assets
cd $NPM_WD
npm install
npx webpack

# hugo build
rm -rf $HUGO_OUTPUT
hugo -b $HUGO_BASE -d $HUGO_OUTPUT -s $GIT_PATH

# copy to dest
[ -d "$DEST" ] && mv $DEST $DEST_TMP
mkdir -p $DEST && cp -r $HUGO_OUTPUT $DEST
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Copy failed, trying to revert"
    rm -rf $DEST
    mv $DEST_TMP $DEST
else
    rm -rf $DEST_TMP
    echo "Completed at $DEST"
fi
