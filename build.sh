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
current_branch="$(git rev-parse --abbrev-ref HEAD)"
latest_tag_name="$(git tag --sort=committerdate | tail -n1)"
latest_tag_code="$(echo "$latest_tag_name" | awk -F '[v._]' '{printf "%02i%02i%02i",$2,$3,$4;}')"
latest_tag_code_num="$(echo "$latest_tag_name" | awk -F '[v._]' '{printf "%01i%02i%02i",$2,$3,$4;}')"

# target HEAD if release is not specified
[ ! "$1" == "release" ] && {
    latest_tag_name="$current_branch"
}

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

logme stats main "name=$latest_tag_name"
logme stats main "code=$latest_tag_code"
logme stats main "beta=$latest_tag_beta"
logme stats main "branch=$current_branch"

# disable building unless we are on bleeding
[ ! "$current_branch" = "bleeding" ] && {
    logme error main "I cannot bluild here @$current_branch. Please switch to bleeding Branch"
    exit 1
}


# if version is beta update json_beta
# if version is non-beta update json & json_beta 


# module_beta.prop
updateJsonUrl_beta="https:\/\/raw.githubusercontent.com\/nivranaitsirhc\/dynmountx\/bleeding\/configs\/update_beta.json"
updateJsonChangelog_beta="https:\/\/raw.githubusercontent.com\/nivranaitsirhc\/dynmountx\/bleeding\/changelog.md"
set_prop version        "$latest_tag_name"              "$ROOTDIR/configs/module_beta.prop"
set_prop versionCode    "$latest_tag_code_num"          "$ROOTDIR/configs/module_beta.prop"
set_prop updateJson     "$updateJsonUrl_beta"           "$ROOTDIR/configs/module_beta.prop"
set_prop changelog      "$updateJsonChangelog_beta"     "$ROOTDIR/configs/module_beta.prop"

# module.prop
[ $latest_tag_beta = false ] && {
updateJsonUrl="https:\/\/raw.githubusercontent.com\/nivranaitsirhc\/dynmountx\/main\/configs\/update.json"
updateJsonChangelog="https:\/\/raw.githubusercontent.com\/nivranaitsirhc\/dynmountx\/main\/changelog.md"
set_prop version        "$latest_tag_name"              "$ROOTDIR/configs/module.prop"
set_prop versionCode    "$latest_tag_code_num"          "$ROOTDIR/configs/module.prop"
set_prop updateJson     "$updateJsonUrl"                "$ROOTDIR/configs/module.prop"
set_prop changelog      "$updateJsonChangelog"          "$ROOTDIR/configs/module.prop"
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
    find ../build -name "*.sh" -exec sed -i '/^\s*# /d;/^\s*$/d' {} \;
    zip -r -9 "$ROOTDIR/release/$target_zip_release_channel" ./
}
cd ../

printf "\n"
printf "%s\n" "--------------------------------------------"
printf "Updating User Changelog..\n"
printf "%s\n" "--------------------------------------------"

target_usr_changelog="changelog.md"

printf "%s\n" "# Dynamic Mount ~ Changelog" > "$ROOTDIR/$target_usr_changelog"
TAG_NOW=$latest_tag_name
git tag --sort=-committerdate | while read -r TAG_PREVIOUS; do
    [ ! "$TAG_PREVIOUS" = "" ] && {
        # diff="$(git log ${TAG_PREVIOUS}..${TAG_NOW} --pretty=format:"%h (%an) %s" --no-merges | grep -v "docs\|bump\|repository\|builder\|git" | sed -E 's/^/- /g')"
        diff="$(git log ${TAG_PREVIOUS}..${TAG_NOW} --pretty=format:"%h %s (%an)" --no-merges | grep -E '\[(core|feature|fix|regression)\]' | sort --key=1.10 | while read -ra LINE; do printf "%s %-15s \n    - %s  \n" "- ${LINE[*]:0:1}" "${LINE[*]:1:1}" "${LINE[*]:2}"; done)"
        [ ! "$diff" = "" ] && {
            # printf "%s\n" "## $(echo "$TAG_NOW" | awk -F '[v._]' '{printf "%02i.%02i.%02i",$2,$3,$4;}') - $TAG_NOW " >> "$ROOTDIR/changelog.md"
            printf "%s\n" "## $TAG_NOW " >> "$ROOTDIR/$target_usr_changelog"
            printf "%s\n" "$diff  " >> "$ROOTDIR/$target_usr_changelog"
        }
    }
    TAG_NOW=$TAG_PREVIOUS
done
printf "%s\n" "## v1.0.0" >> "$ROOTDIR/$target_usr_changelog"
printf "%s\n" "- Initial Release" >> "$ROOTDIR/$target_usr_changelog"

cat "$ROOTDIR/$target_usr_changelog"

printf "\n"
printf "%s\n" "--------------------------------------------"
printf "Updating Dev Changelog..\n"
printf "%s\n" "--------------------------------------------"

target_dev_changelog=changelog_dev.md

printf "%s\n" "# Dynamic Mount ~ Changelog" > "$ROOTDIR/$target_dev_changelog"
TAG_NOW=$latest_tag_name
git tag --sort=-committerdate | while read -r TAG_PREVIOUS; do
    [ ! "$TAG_PREVIOUS" = "" ] && {
        # diff="$(git log ${TAG_PREVIOUS}..${TAG_NOW} --pretty=format:"%h (%an) %s" --no-merges | grep -v "docs\|bump\|repository\|builder\|git" | sed -E 's/^/- /g')"
        diff="$(git log ${TAG_PREVIOUS}..${TAG_NOW} --pretty=format:"%h %s (%an)" --no-merges | grep -E -v '\[(bump|git|release)\]' | while read -ra LINE; do printf "%s %-15s \n    - %s  \n" "- ${LINE[*]:0:1}" "${LINE[*]:1:1}" "${LINE[*]:2}"; done)"
        [ ! "$diff" = "" ] && {
            # printf "%s\n" "## $(echo "$TAG_NOW" | awk -F '[v._]' '{printf "%02i.%02i.%02i",$2,$3,$4;}') - $TAG_NOW " >> "$ROOTDIR/changelog.md"
            printf "%s\n" "## $TAG_NOW " >> "$ROOTDIR/$target_dev_changelog"
            printf "%s\n" "$diff  " >> "$ROOTDIR/$target_dev_changelog"
        }
    }
    TAG_NOW=$TAG_PREVIOUS
done
printf "%s\n" "## v1.0.0" >> "$ROOTDIR/$target_dev_changelog"
printf "%s\n" "- Initial Release" >> "$ROOTDIR/$target_dev_changelog"

cat "$ROOTDIR/$target_dev_changelog"


[ "$1" == "release" ] && {
    logme stats main "committing build..."
    git add changelog.md changelog_dev.md configs && \
    git commit -m "[release] build.sh invoked relase for $latest_tag_name @ $(date)"
    echo "added commit"
}