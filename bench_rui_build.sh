#!/bin/bash
#
# Copyright (c) 2024 Numurus <https://www.numurus.com>.
#
# This file is part of nepi engine ws (nepi_engine_ws) repo
# (see https://github.com/nepi-engine/nepi_engine_ws)
#
# RUI build-speed benchmark.
#
# Times the npm build alone (no rsync/setup preamble) across several
# configurations so we can see which levers actually pay off on THIS hardware.
# Run it directly on the device:
#
#     bash /mnt/nepi_storage/nepi_src/nepi_engine_ws/bench_rui_build.sh
#
# It leaves the RUI rebuilt with the default configuration, so the deployed
# build is correct when it finishes.

set -u

NEPI_USER=${NEPI_USER:-nepi}
NEPI_HOME=${NEPI_HOME:-/home/${NEPI_USER}}
NEPI_BASE=${NEPI_BASE:-/opt/nepi}
APP_DIR="${NEPI_BASE}/nepi_rui/src/rui_webserver/rui-app"

HIGHLIGHT='\033[1;34m'
CLEAR='\033[0m'

if [[ ! -d "$APP_DIR" ]]; then
    echo "ERROR: ${APP_DIR} not found. Run a normal ruibld first."
    exit 1
fi

# npm comes from nvm, which a plain login shell does not have on PATH.
if [[ -f ${NEPI_HOME}/.nvm/nvm.sh ]]; then
    source ${NEPI_HOME}/.nvm/nvm.sh
fi
if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm not on PATH even after sourcing nvm."
    echo "       Try: source ${NEPI_HOME}/.nvm/nvm.sh && nvm ls"
    exit 1
fi

cd "$APP_DIR" || exit 1

export GENERATE_SOURCEMAP=false
export CI=false

CACHE_DIR="${APP_DIR}/node_modules/.cache"

echo ""
echo "=============================================="
echo " RUI build benchmark"
echo "=============================================="
echo "node    : $(node -v 2>/dev/null)"
echo "npm     : $(npm -v 2>/dev/null)"
echo "cores   : $(nproc 2>/dev/null)"
echo "memfree : $(free -m 2>/dev/null | awk '/Mem:/{print $7" MB avail"}')"
echo ""

# The babel cache is the single largest lever already in place, and it fails
# silently: if node_modules/.cache is not writable by the build user,
# babel-loader quietly falls back to /tmp instead of erroring. Report it.
echo "babel cache dir : ${CACHE_DIR}"
if [[ -e "$CACHE_DIR" ]]; then
    echo "  exists        : yes ($(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1))"
    echo "  owner         : $(stat -c '%U:%G' "$CACHE_DIR" 2>/dev/null)"
else
    echo "  exists        : no (will be created on first build)"
fi
echo "  running as    : $(id -un)"
if [[ -w "${APP_DIR}/node_modules" ]]; then
    echo "  node_modules  : writable -> cache will persist here"
else
    echo "  node_modules  : NOT WRITABLE -> babel will fall back to /tmp"
fi
echo ""

results=()

run_build() {
    local label="$1"; shift
    rm -rf build
    local start=$(date +%s)
    if ! env "$@" npm run build > /tmp/rui_bench_last.log 2>&1; then
        echo "  ${label}: FAILED (see /tmp/rui_bench_last.log)"
        results+=("${label}|FAILED|-")
        return
    fi
    local elapsed=$(( $(date +%s) - start ))
    local gz="-"
    if command -v gzip >/dev/null 2>&1; then
        gz="$(( $(cat build/static/js/*.js | gzip -c | wc -c) / 1024 ))KB"
    fi
    echo "  ${label}: ${elapsed}s  (gzip ${gz})"
    results+=("${label}|${elapsed}s|${gz}")
}

echo "--- [0/5] cold build: clearing babel cache ---"
rm -rf "$CACHE_DIR"
run_build "0 cold (no babel cache)   "

echo ""
echo "--- [1/5] warm baseline (this is your current ruibld) ---"
run_build "1 warm baseline           "

echo ""
echo "--- [2/5] warm, lint skipped ---"
run_build "2 warm + skip lint        " RUI_SKIP_LINT=1

echo ""
echo "--- [3/5] warm, uglify compress off ---"
run_build "3 warm + no compress      " RUI_NO_COMPRESS=1

echo ""
echo "--- [4/5] warm, both ---"
run_build "4 warm + skip lint + nocmp" RUI_SKIP_LINT=1 RUI_NO_COMPRESS=1

echo ""
echo "--- [5/5] restoring default build ---"
run_build "5 warm baseline (repeat)  "

echo ""
printf "${HIGHLIGHT}=============================================="
printf "\n RESULTS\n"
printf "==============================================${CLEAR}\n"
printf "%-28s %8s %10s\n" "config" "time" "bundle"
for r in "${results[@]}"; do
    IFS='|' read -r a b c <<< "$r"
    printf "%-28s %8s %10s\n" "$a" "$b" "$c"
done
echo ""
echo "Rows 1 and 5 are the same config -- the gap between them is your noise floor."
echo "Row 0 minus row 1 is what the babel cache is worth."
echo "The deployed build is now the default configuration."
echo ""
