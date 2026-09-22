# conduit-spec

RealWorld(Conduit)の契約。conduit-api と conduit-web はこの repo の内容に従う。

- `api/openapi.yml`: API 仕様(公式そのまま)
- `api/hurl/`: API 適合テスト。`HOST=http://localhost:3000 ./api/run-api-tests-hurl.sh [files...]`
- `e2e/`: フロントの E2E テスト(Playwright)。`e2e/SELECTORS.md` がセレクタ契約
- `theme/styles.css`: 公式の CSS テーマ
- `decisions.md`: 仕様が曖昧な点に対する本プロジェクトの決定
- `UPSTREAM.md` / `UPSTREAM.lock`: 取り込み元と pin

公式から取り込んだファイルは改変しない。CI は `scripts/check-upstream.sh` で lock との一致だけを確認する。
