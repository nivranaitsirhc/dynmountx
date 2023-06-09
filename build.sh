#!/bin/bash
# shellcheck shell=bash
# shellcheck source=/dev/null

# ROOTDIR="${0%/*}"
ROOTDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

set_prop(){
    # logme debug set_prop "$1, $2, $3"
    [ -z "$1" ] && {
        logme debug set_prop "s1 failed"
        return 1 # key
    }
    [ -z "$2" ] && {
        logme debug set_prop "s2 failed"
        return 1 # value
    }
    [ ! -f "$3" ] && {
        logme debug set_prop "s3 failed"
        return 1 # full file path
    }
    # logme debug set_prop "sed -i'' -q -E \"s/^$1=.*/$1=$2/g\" \"$3\""
    eval "sed -i'' -E \"s/^$1=.*/$1=$2/g\" \"$3\""
}
set_prop_description(){
    [ -z "$1" ] && return 1 # key
    [ -z "$2" ] && return 1 # value
    [ ! -f "$3" ] && return 1 # full file path
    sed -E "s/^$1=(\[.*][[:space:]]*)?/$1=[ $2 ] /g" "$3"
}
set_prop_json(){
    # logme debug set_prop_json "$1, $2, $3"
    [ -z "$1" ] && {
        logme debug set_prop "s1 failed"
        return 1 # key
    }
    [ -z "$2" ] && {
        logme debug set_prop "s2 failed"
        return 1 # value
    }
    [ ! -f "$3" ] && {
        logme debug set_prop "s3 failed"
        return 1 # full file path
    }
    # logme debug set_prop_json "sed  -i'' -E 's/\"$1\".*/\"$1\": \"$2\",/g' \"$3\""
    if echo "$2" | grep -q -E '^[0-9]+$';then
        eval "sed  -i'' -E 's/\"$1\".*/\"$1\": $2,/g' \"$3\""
    else
        eval "sed  -i'' -E 's/\"$1\".*/\"$1\": \"$2\",/g' \"$3\""
    fi
}

logme () {
    printf "%-6s %-10s : %s\n" "$1" "$2" "$3"
}

# get latest tag
# latest_tag_name="$(git describe --tags --abbrev=0)"
latest_tag_name="$(git tag --sort=committerdate | tail -n1)"
latest_tag_code="$(echo "$latest_tag_name" | awk -F '[v._]' '{printf "%02i%02i%02i",$2,$3,$4;}')"
latest_tag_code_num="$(echo "$latest_tag_name" | awk -F '[v._]' '{printf "%01i%02i%02i",$2,$3,$4;}')"
if echo "$latest_tag_name" | grep -q beta; then
    latest_tag_beta=true
else
    latest_tag_beta=false
fi

target_zip_release_channel=dynmountx_${latest_tag_name}_release.zip
target_zip_beta_channel=dynmountx_${latest_tag_name}_beta-channel.zip

printf "\n"
printf "%s\n" "--------------------------------------------"
printf "Getting latest config from GIT....\n"
printf "%s\n" "--------------------------------------------"

logme debug main "name=$latest_tag_name"
logme debug main "code=$latest_tag_code"
logme debug main "beta=$latest_tag_beta"


# if version is beta update json_beta
# if version is non-beta update json & json_beta 


# module_beta.prop
updateJsonUrl_beta="https:\/\/raw.githubusercontent.com\/nivranaitsirhc\/dynmountx\/main\/configs\/update_beta.json"
set_prop version        "$latest_tag_name"              "$ROOTDIR/configs/module_beta.prop"
set_prop versionCode    "$latest_tag_code_num"          "$ROOTDIR/configs/module_beta.prop"
set_prop updateJson     "$updateJsonUrl_beta"           "$ROOTDIR/configs/module_beta.prop"

# module.prop
[ $latest_tag_beta = false ] && {
updateJsonUrl="https:\/\/raw.githubusercontent.com\/nivranaitsirhc\/dynmountx\/main\/configs\/update.json"
set_prop version        "$latest_tag_name"              "$ROOTDIR/configs/module.prop"
set_prop versionCode    "$latest_tag_code_num"          "$ROOTDIR/configs/module.prop"
set_prop updateJson     "$updateJsonUrl"                "$ROOTDIR/configs/module.prop"
}


# update_beta.json
zipUrl="https:\/\/github.com\/nivranaitsirhc\/dynmountx\/releases\/download\/$latest_tag_name\/$target_zip_beta_channel"
set_prop_json "version"       "$latest_tag_name"        "$ROOTDIR/configs/update_beta.json"
set_prop_json "versionCode"   "$latest_tag_code_num"    "$ROOTDIR/configs/update_beta.json"
set_prop_json "zipUrl"        "$zipUrl"                 "$ROOTDIR/configs/update_beta.json"

# update.json
[ "$latest_tag_beta" = false ] && {
zipUrl="https:\/\/github.com\/nivranaitsirhc\/dynmountx\/releases\/download\/$latest_tag_name\/$target_zip_release_channel"
set_prop_json "version"       "$latest_tag_name"        "$ROOTDIR/configs/update.json"
set_prop_json "versionCode"   "$latest_tag_code_num"    "$ROOTDIR/configs/update.json"
set_prop_json "zipUrl"        "$zipUrl"                 "$ROOTDIR/configs/update.json"
}

# view comfing files
printf "\n"
printf "%s\n" "--------------------------------------------"
printf " Loading config files\n"
printf "%s\n" "--------------------------------------------"
printf "\n"
printf "\nmodule_beta.prop\n"
printf "%s\n" "--------------------------------------------"
cat "$ROOTDIR/configs/module_beta.prop"
printf "\n"
[ $latest_tag_beta = false ] && {
printf "\nmodule.prop\n"
printf "%s\n" "--------------------------------------------"
cat "$ROOTDIR/configs/module.prop"
printf "\n"
}
printf "\nupdate_beta.json\n"
printf "%s\n" "--------------------------------------------"
cat "$ROOTDIR/configs/update_beta.json"
printf "\n"
[ $latest_tag_beta = false ] && {
printf "\nupdate.json\n"
printf "%s\n" "--------------------------------------------"
cat "$ROOTDIR/configs/update.json"
printf "\n"
}

[ ! -d "$ROOTDIR/build" ] && mkdir -p "$ROOTDIR/build"
[ ! -d "$ROOTDIR/release" ] && mkdir -p "$ROOTDIR/release"
printf "\n"
printf "%s\n" "--------------------------------------------"
printf "Building Modules...\n"
printf "%s\n" "--------------------------------------------"


printf "\n%s\n" "Building Beta Channel"
printf "%s\n" "--------------------------------------------"
# clear build dir
rm -rf "${ROOTDIR:?}/build/*"
# copy src files
cp -rf "${ROOTDIR}/src/." "${ROOTDIR}/build"
# cd to build dir
cd ./build || exit 1
cp -rf "$ROOTDIR/configs/module_beta.prop" "$ROOTDIR/build/module.prop"
zip -r -9 "$ROOTDIR/release/$target_zip_beta_channel" ./
[ $latest_tag_beta = false ] && {
    printf "\n%s\n" "Building Release Channel"
    printf "%s\n" "--------------------------------------------"
    cp -rf "$ROOTDIR/configs/module.prop" "$ROOTDIR/build/module.prop"
    # trim files
    find ./build -name "*.sh" -exec sed -i '/^\s*# /d;/^\s*$/d;/logme debug/d' {} \;
    zip -r -9 "$ROOTDIR/release/$target_zip_release_channel" ./
}
cd ../

printf "\n"
printf "%s\n" "--------------------------------------------"
printf "Updating Changelog..\n"
printf "%s\n" "--------------------------------------------"


printf "%s\n" "# Dynamic Mount ~ Changelog" > "$ROOTDIR/changelog.md"
TAG_NOW=$latest_tag_name
git tag --sort=-committerdate | while read -r TAG_PREVIOUS; do
    [ ! "$TAG_PREVIOUS" = "" ] && {
        diff="$(git log ${TAG_PREVIOUS}..${TAG_NOW} --pretty=format:"%h - (%an) %s" --no-merges | grep -v "bump\|repository\|builder\|git" | sed -E 's/^/- /g')"
        [ ! "$diff" = "" ] && {
            printf "%s\n" "## $(echo "$TAG_NOW" | awk -F '[v._]' '{printf "%02i.%02i.%02i",$2,$3,$4;}') - $TAG_NOW " >> "$ROOTDIR/changelog.md"
            printf "%s\n" "$diff" >> "$ROOTDIR/changelog.md"
        }
    }
    TAG_NOW=$TAG_PREVIOUS
done
printf "%s\n" "## 01.00.00 - (v1.0.0)" >> "$ROOTDIR/changelog.md"
printf "%s\n" "- Initial Release" >> "$ROOTDIR/changelog.md"

cat "$ROOTDIR/changelog.md"