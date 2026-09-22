#!/usr/bin/env bash
# 取り込みファイルの sha256 一覧を出力する(UPSTREAM.lock の生成と検証に使う)
set -euo pipefail
cd "$(dirname "$0")/.."
find api e2e theme LICENSE.upstream -type f | LC_ALL=C sort | while read -r f; do
  printf '%s  %s\n' "$(shasum -a 256 "$f" | cut -d' ' -f1)" "$f"
done
