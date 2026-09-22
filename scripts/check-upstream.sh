#!/usr/bin/env bash
# UPSTREAM.lock と実ファイルのハッシュが一致するか確認する
set -euo pipefail
cd "$(dirname "$0")/.."
diff <(./scripts/hash-upstream.sh) UPSTREAM.lock && echo "upstream files match UPSTREAM.lock"
