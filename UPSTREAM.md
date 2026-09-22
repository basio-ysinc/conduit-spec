# Upstream

取り込み元: https://github.com/gothinkster/realworld
コミット: ebbcdeb8d55b42a3a613c787560498b8ef10003f

| 本 repo | 取り込み元 |
|---|---|
| api/openapi.yml | specs/api/openapi.yml |
| api/hurl/ | specs/api/hurl/ |
| api/run-api-tests-hurl.sh | specs/api/run-api-tests-hurl.sh |
| e2e/ | specs/e2e/ |
| theme/styles.css | assets/theme/styles.css |
| LICENSE.upstream | LICENSE |

取り込んだファイルは改変しない。更新は `scripts/sync-upstream.sh <commit>` で行い、`UPSTREAM.lock` を再生成する。CI は lock と実ファイルのハッシュ一致だけを確認する。
