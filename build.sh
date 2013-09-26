#!/usr/bin/env bash

function check_result {
  if [ "0" -ne "$?" ]
  then
    (repo forall -c "git reset --hard") >/dev/null
    rm -f .repo/local_manifests/dyn-*.xml
    rm -f .repo/local_manifests/roomservice.xml
    echo $1
    exit 1
  fi
}

if [ -z "$REPO_BRANCH" ]
then
	if [ -z "$2" ]
	then
		export REPO_BRANCH=cd-4.3
	else
		export REPO_BRANCH=$2
	fi
fi

if [ -z "$DEVICE" ]
then
  export DEVICE=$1
fi

if [ -z "$SYNC_PROTO" ]
then
  SYNC_PROTO=http
fi
export LUNCH=cd_$DEVICE-userdebug

# colorization fix in Jenkins
export CL_RED="\"\033[31m\""
export CL_GRN="\"\033[32m\""
export CL_YLW="\"\033[33m\""
export CL_BLU="\"\033[34m\""
export CL_MAG="\"\033[35m\""
export CL_CYN="\"\033[36m\""
export CL_RST="\"\033[0m\""

export PATH=~/bin:$PATH

export USE_CCACHE=1
export CCACHE_NLEVELS=4
export BUILD_WITH_COLORS=0

platform=`uname -s`
if [ "$platform" = "Darwin" ]
then
  export BUILD_MAC_SDK_EXPERIMENTAL=1
fi

REPO=$(which repo)
if [ -z "$REPO" ]
then
  mkdir -p ~/bin
  curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > ~/bin/repo
  chmod a+x ~/bin/repo
fi

# always force a fresh repo init since we can build off different branches
# and the "default" upstream branch can get stuck on whatever was init first.
if [ -z "$CORE_BRANCH" ]
then
  CORE_BRANCH=$REPO_BRANCH
fi

if [ ! -z "$RELEASE_MANIFEST" ]
then
  MANIFEST="-m $RELEASE_MANIFEST"
else
  RELEASE_MANIFEST=""
  MANIFEST=""
fi

rm -rf .repo/manifests*
rm -f .repo/local_manifests/dyn-*.xml
repo init -u $SYNC_PROTO://github.com/CyanDreamProject/android.git -b $CORE_BRANCH $MANIFEST
check_result "repo init failed."

# make sure ccache is in PATH
if [ "$REPO_BRANCH" = "cd-4.3" ]
then
export PATH="$PATH:/opt/local/bin/:$PWD/prebuilts/misc/$(uname|awk '{print tolower($0)}')-x86/ccache"
export CCACHE_DIR=~/.jb_ccache
else
export PATH="$PATH:/opt/local/bin/:$PWD/prebuilt/$(uname|awk '{print tolower($0)}')-x86/ccache"
export CCACHE_DIR=~/.ics_ccache
fi

if [ -f ~/.jenkins_profile ]
then
  . ~/.jenkins_profile
fi

mkdir -p .repo/local_manifests
rm -f .repo/local_manifest.xml
rm -f .repo/local_manifests/device.xml

if [ "$DEVICE" = "ace" ]
then
  cp local_manifests/ace_manifest.xml .repo/local_manifests/device.xml
elif [ "$DEVICE" = "bravo" ]
then
  cp local_manifests/bravo_manifest.xml .repo/local_manifests/device.xml
else
  echo a local_manifest does not exist, skipping.
fi

check_result "Bootstrap failed"

echo Core Manifest:
cat .repo/manifest.xml

# delete symlink for vendor before sync
rm -rf vendor/cm

echo Syncing...
repo sync -d -c > /dev/null
check_result "repo sync failed."

echo Sync complete.

vendor/cyandream/get-prebuilts

# workaround for devices that are not 100% supported by CyanDream
echo creating symlink...
ln -s vendor/cyandream vendor/cm

if [ -f .last_branch ]
then
  LAST_BRANCH=$(cat .last_branch)
else
  echo "Last build branch is unknown, assume clean build"
  LAST_BRANCH=$REPO_BRANCH-$CORE_BRANCH$RELEASE_MANIFEST
fi

. build/envsetup.sh

lunch $LUNCH
check_result "lunch failed."

# save manifest used for build (saving revisions as current HEAD)

# save it
repo manifest -o $WORKSPACE/archive/manifest.xml -r

rm -f $OUT/CyanDream-*.zip*
rm -f $OUT/system/build.prop

UNAME=$(uname)

if [ ! "$(ccache -s|grep -E 'max cache size'|awk '{print $4}')" = "100.0" ]
then
  ccache -M 20G
fi

time mka bacon

check_result "Build failed."

rm -f .repo/local_manifests/roomservice.xml