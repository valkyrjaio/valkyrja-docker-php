#!/usr/bin/env bash
#
# This file is part of the Valkyrja Docker package.
#
# Copyright (c) 2016-present Melech Mizrachi
#
# Released under the MIT License. See LICENSE.md for details.
#
# ---------------------------------------------------------------------------
# Copyright header check.
#
# Every program file in this repository carries the copyright header that
# COPYRIGHT_HEADER.md in the .github repository specifies. This repository runs
# no language tool, so no formatter adds the header and no linter reports a
# wrong one. This script is the mechanism instead.
#
# The check is closed by default. It reads every tracked file, and it requires
# the header in each file that EXCLUDED does not match. A new file fails the
# check until a person adds the header, or adds the file to EXCLUDED. A file
# that holds no program code belongs in EXCLUDED. A document, a workflow, and a
# configuration file are such files, and the organization gives none of them the
# header.
#
# Usage:
#
#     ./.github/ci/copyright-header/check.sh

set -euo pipefail

cd "$(dirname "$0")/../../.."

readonly SCRIPT_PATH='.github/ci/copyright-header/check.sh'

# The package identifier for this repository. COPYRIGHT_HEADER.md in the .github
# repository maps each repository to its own identifier.
readonly IDENTIFIER='Valkyrja Docker'

# The files that carry no copyright header.
readonly EXCLUDED=(
    '.dockerignore'
    '.gitignore'
    '*.md'
    '*.yml'
    'docker/apt/sources.list'
    'docker/conf/site.conf'
)

readonly TEXT_1="This file is part of the ${IDENTIFIER} package."
readonly TEXT_2='Copyright (c) 2016-present Melech Mizrachi'
readonly TEXT_3='Released under the MIT License. See LICENSE.md for details.'

# A PHP file writes the header as a block comment.
readonly BLOCK_COMMENT="/*
 * ${TEXT_1}
 *
 * ${TEXT_2}
 *
 * ${TEXT_3}
 */"

# Every other file writes the same text as a line comment.
readonly LINE_COMMENT="#
# ${TEXT_1}
#
# ${TEXT_2}
#
# ${TEXT_3}
#"

is_excluded() {
    local path="$1"
    local pattern

    for pattern in "${EXCLUDED[@]}"; do
        # shellcheck disable=SC2053
        if [[ "$path" == $pattern ]]; then
            return 0
        fi
    done

    return 1
}

expected_header() {
    case "$1" in
        *.php) printf '%s' "$BLOCK_COMMENT" ;;
        *) printf '%s' "$LINE_COMMENT" ;;
    esac
}

failed=0

while IFS= read -r -d '' path; do
    if is_excluded "$path"; then
        continue
    fi

    expected="$(expected_header "$path")"

    # The header sits at the top of the file. A shebang precedes it, and a PHP
    # open tag precedes it, so the first line of the header is not always the
    # first line of the file. Reading the first 12 lines accepts every such
    # opening, and rejects a header that sits further down the file.
    if [[ "$(head -n 12 "$path")" != *"$expected"* ]]; then
        printf 'Missing or wrong copyright header: %s\n' "$path" >&2
        failed=1
    fi
done < <(git ls-files -z)

if [[ "$failed" -ne 0 ]]; then
    printf '\nEach file above must carry this header:\n\n%s\n\n' "$LINE_COMMENT" >&2
    printf 'A PHP file writes the same text as a block comment.\n' >&2
    printf 'A file that holds no program code belongs in EXCLUDED in %s.\n' "$SCRIPT_PATH" >&2

    exit 1
fi

printf 'Every file carries the copyright header.\n'
