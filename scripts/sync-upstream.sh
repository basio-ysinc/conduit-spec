#!/usr/bin/env bash
# 指定コミットの gothinkster/realworld から取り込みファイルを更新し、lock を再生成する
set -euo pipefail
COMMIT="${1:?usage: sync-upstream.sh <commit>}"
cd "$(dirname "$0")/.."
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
git clone -q https://github.com/gothinkster/realworld.git "$TMP/rw"
git -C "$TMP/rw" checkout -q "$COMMIT"
rm -rf api/hurl e2e; mkdir -p api e2e theme
cp "$TMP/rw/specs/api/openapi.yml" "$TMP/rw/specs/api/run-api-tests-hurl.sh" api/
cp -R "$TMP/rw/specs/api/hurl" api/hurl
cp -R "$TMP/rw/specs/e2e/." e2e/
cp "$TMP/rw/assets/theme/styles.css" theme/
cp "$TMP/rw/LICENSE" LICENSE.upstream
sed -i '' -E "s/^コミット: .*/コミット: $(git -C "$TMP/rw" rev-parse HEAD)/" UPSTREAM.md
./scripts/hash-upstream.sh > UPSTREAM.lock
echo "synced to $COMMIT"
