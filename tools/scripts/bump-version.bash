#!/usr/bin/env bash
#
# -----------------------------------------------------------
#
# Increments the semantic version string in the given file.
#
# Bumps all three layers based on the field to increment.
#
# $1 - bump which field [major | minor | patch]
# $2 - version file
#
# Version file consists of just a single line who's
# contents look like "1.2.3" (no quotes).
#
# Example: bump-version.bash minor ./version.txt
#
# -----------------------------------------------------------
#
incrementSemanticVersion()
{ 
    # $1 - level to incr [major|minor|patch]
    # $2 - version string e.g. "1.2.4"

    level=$1
    IFS='.' read -ra ver <<< "$2"
    [[ "${#ver[@]}" -ne 3 ]] && echo "Invalid version string: $2" && return 1

    patch=${ver[2]}
    minor=${ver[1]}
    major=${ver[0]}

    case $level in
        patch)
            patch=$((patch+1))
        ;;
        minor)
            patch=0
            minor=$((minor+1))
        ;;
        major)
            patch=0
            minor=0
            major=$((major+1))
        ;;
        *)
            echo "Invalid level passed: \"$level\""
            return 2
    esac
    echo "$major.$minor.$patch"
}

# -----------------------------------------------------------

usage()
{
    echo $1
    echo "Usage: $(basename $0) <major|minor|patch> <version file>"
    exit 1
}

# -----------------------------------------------------------

[[ $# -ne 2 ]] && usage "Missing arguments"
[[ ! -f $2  ]] && usage "No such file: $2"

oldTriplet=$(cat $2)

declare -i ret
newTriplet=$(incrementSemanticVersion $1 $oldTriplet)
ret=$?
[[ $ret -ne 0 ]] && echo "Failed to bump version: $newTriplet" && exit 1

echo "$newTriplet" > $2

# echo "Old version: $oldTriplet"
# echo "New version: $newTriplet"

# -----------------------------------------------------------
