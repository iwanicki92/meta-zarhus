#!/usr/bin/env bash

set -euo pipefail

print_usage() {
    cat <<EOF
Usage: $(basename "$0") <tag_version>

Generate release notes for <tag_version> by parsing CHANGELOG.md.
EOF
}

# version without 'v'
CURRENT_VERSION="${1#v}"
if [ -z "$CURRENT_VERSION" ]; then
    print_usage
    exit 1
elif [[ "$CURRENT_VERSION" == "-h" || "$CURRENT_VERSION" == "--help" ]]; then
    print_usage
    exit 0
fi

cd "$(git -C "$(dirname "$(realpath "$0")")" rev-parse --show-toplevel)"
CHANGELOG_PATH="CHANGELOG.md"
VERSIONS="$(grep "^## " $CHANGELOG_PATH | awk '{print $2}')"
PREVIOUS_VERSION="$(echo "$VERSIONS" | awk "/$CURRENT_VERSION/ {y=1; next} y != 0 {print; exit}")"

START_CHANGELOG=$(grep -m2 -n "## $CURRENT_VERSION" $CHANGELOG_PATH | head -n1 | cut -d: -f1)
END_CHANGELOG=$(grep -m2 -n "## $PREVIOUS_VERSION" $CHANGELOG_PATH | tail -n1 | cut -d: -f1)

REPOSITORY="$(gh repo view --json nameWithOwner | jq -r '.nameWithOwner')"

cat <<EOF
# What's changed

$(awk "NR >= $START_CHANGELOG && NR < $END_CHANGELOG" $CHANGELOG_PATH)

**Full changelog**: https://github.com/${REPOSITORY}/compare/v${PREVIOUS_VERSION}...v${CURRENT_VERSION}
EOF
