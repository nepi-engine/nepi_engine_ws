#!/bin/bash
#
# Copyright (c) 2026 Numurus <https://www.numurus.com>.
#
# This file is part of nepi engine ws (nepi_engine_ws) repo
# (see https://github.com/nepi-engine/nepi_engine_ws)
#
# License: NEPI Engine WS Tools and NEPI software deployed and/or compiled with these tools
# are licensed under the "Numurus Software License",
# which can be found at: <https://numurus.com/wp-content/uploads/Numurus-Software-License-Terms.pdf>
#
# Redistributions in source code must retain this top-level comment block.
# Plagiarizing this software to sidestep the license obligations is illegal.
#
# Contact Information:
# ====================
# - mailto:nepi@numurus.com
#
#
# Build a single self-contained source archive for a NEPI release tag.
#
# GitHub's auto-generated "Source code (zip/tar.gz)" on a release page does NOT
# include submodule contents -- git archive does not follow gitlinks, so a
# downloader gets ten empty directories. This script inlines every submodule so
# the resulting tarball is what people actually expect when they click Download.
#
# Usage:
#   ./make_nepi_release_archive.sh v3.3.0 [output_dir]
#
# Output:
#   <output_dir>/nepi_engine_ws-<tag>.tar.gz
#   <output_dir>/nepi_engine_ws-<tag>.tar.gz.sha256
#
# Attach both to the GitHub release. The archive contains no .git metadata, so
# it is source-only -- it is not a clone and cannot be used to push.

set -euo pipefail

TAG="${1:-}"
OUT_DIR="${2:-$(pwd)}"

if [ -z "$TAG" ]; then
    echo "ERROR: no tag given."
    echo "Usage: $0 <tag> [output_dir]"
    exit 1
fi

WS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$WS_ROOT"

NAME="nepi_engine_ws-${TAG}"
ARCHIVE="${OUT_DIR}/${NAME}.tar.gz"

echo "=============================================="
echo " NEPI release archive"
echo " workspace : $WS_ROOT"
echo " tag       : $TAG"
echo " output    : $ARCHIVE"
echo "=============================================="
echo

# ---------------------------------------------------------------------------
# Preflight: the archive is built from the working tree, so the working tree
# must match the tag exactly. Bail loudly rather than shipping a tarball whose
# contents silently differ from what the tag says.
# ---------------------------------------------------------------------------

if ! git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
    echo "ERROR: tag '$TAG' does not exist in the superproject."
    exit 1
fi

TAG_SHA="$(git rev-list -n1 "$TAG")"
HEAD_SHA="$(git rev-parse HEAD)"

if [ "$TAG_SHA" != "$HEAD_SHA" ]; then
    echo "ERROR: working tree is not checked out at $TAG."
    echo "  HEAD : $HEAD_SHA"
    echo "  $TAG : $TAG_SHA"
    echo "Run: git checkout $TAG && git submodule update --init --recursive"
    exit 1
fi

if [ -n "$(git status --porcelain --ignore-submodules=dirty)" ]; then
    echo "ERROR: superproject has uncommitted changes. Refusing to build a release archive."
    git status --short --ignore-submodules=dirty
    exit 1
fi

# Every submodule must sit on the SHA the tag pins. `git submodule status`
# prefixes a mismatched entry with '+' and an uninitialized one with '-'.
echo "Verifying submodule pins..."
bad=0
while read -r line; do
    flag="${line:0:1}"
    path="$(echo "$line" | awk '{print $2}')"
    case "$flag" in
        +) echo "  MISMATCH    $path (checked out != pinned by $TAG)"; bad=1 ;;
        -) echo "  UNINIT      $path (run git submodule update --init --recursive)"; bad=1 ;;
        *) echo "  ok          $path" ;;
    esac
done < <(git submodule status --recursive)

if [ "$bad" -ne 0 ]; then
    echo
    echo "ERROR: submodule state does not match $TAG. Aborting."
    exit 1
fi
echo

# ---------------------------------------------------------------------------
# Stage: superproject first, then each submodule extracted over its own path.
# git archive emits the tree without .git metadata, which is what we want.
# ---------------------------------------------------------------------------

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
STAGE="${TMP_DIR}/${NAME}"
mkdir -p "$STAGE"

echo "Staging superproject..."
git archive --format=tar "$TAG" | tar -x -C "$STAGE"

echo "Staging submodules..."
# --recursive covers any nested submodules. $displaypath is the path relative
# to the superproject root, which is exactly where the content belongs.
git submodule foreach --recursive --quiet '
    echo "  + $displaypath"
    mkdir -p "'"$STAGE"'/$displaypath"
    git archive --format=tar HEAD | tar -x -C "'"$STAGE"'/$displaypath"
'

# Record what actually went in, so the tarball is self-describing.
{
    echo "NEPI Engine Workspace release archive"
    echo "tag: ${TAG}"
    echo "superproject: ${TAG_SHA}"
    echo
    echo "submodule pins:"
    git submodule status --recursive | awk '{printf "  %-28s %s\n", $2, $1}'
} > "${STAGE}/RELEASE_MANIFEST.txt"

echo
echo "Compressing..."
mkdir -p "$OUT_DIR"
tar -czf "$ARCHIVE" -C "$TMP_DIR" "$NAME"

( cd "$OUT_DIR" && sha256sum "${NAME}.tar.gz" > "${NAME}.tar.gz.sha256" )

echo
echo "=============================================="
echo " Done."
echo "   $ARCHIVE"
echo "   $(du -h "$ARCHIVE" | cut -f1)"
echo "   $(cut -d' ' -f1 "${OUT_DIR}/${NAME}.tar.gz.sha256")"
echo "=============================================="
echo
echo "Attach both files to the GitHub release for ${TAG}."
