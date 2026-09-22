# 契約上の決定事項

RealWorld 公式仕様(`api/openapi.yml`)が曖昧な点について、本プロジェクト(conduit-api / conduit-web)が従う決定をここに書く。Jira Epic の TBD 表と 1 対 1 に対応させる。S1 で埋める。

## TBD-1 slug の生成規則と衝突時の扱い

**決定:**

- slug は記事の作成時にタイトルから生成する。形式はタイトルの kebab-case(小文字化し、空白および句読点・記号の連続を 1 個の `-` に置き換え、先頭・末尾の `-` を除去したもの)
- 非 ASCII 文字(日本語等)は除去せずそのまま残す(Unicode slug。URL 上では percent-encoding される)
- 変換結果が空文字列になる場合(空白・記号のみのタイトル等)は、ランダム接尾辞のみを slug とする
- 既存の slug と衝突した場合は、末尾に `-` + 短いランダム接尾辞(例: `my-title-x7k9q2`)を付けて一意にする。接尾辞付きでも衝突した場合は接尾辞を再生成する
- slug は作成時に確定し、以後の記事更新(title 変更を含む)では変更しない

**hurl との整合:** `errors_articles.hurl` の「Duplicate titles are allowed」が同一タイトルの 2 記事で `$.article.slug != {{slug1}}` をアサートし、`articles.hurl` が `$.article.slug isString` と capture した slug による GET / PUT / DELETE の往復をアサートするのと整合する。

## TBD-2 一覧の limit / offset の既定値と上限

**決定:**

- `limit`: 既定値 20、上限 100。`offset`: 既定値 0
- 範囲外の値(`limit` が 1 未満または 100 超過、`offset` が 0 未満)はバリデーションエラーとして 422 を返す。エラー形式は TBD-3 に従う
- `articlesCount` は limit/offset 適用前の総件数を返す
- 対象: `GET /articles`、`GET /articles/feed`、`GET /articles/{slug}/comments` など一覧系エンドポイント

**hurl との整合:** `pagination.hurl` が `limit=1` で `articles` count==1 かつ `articlesCount`==2、`limit=1&offset=1` で 2 件目が返ることをアサートし、`feed.hurl` も `feed?limit=1&offset=1` で同様にアサートするのと整合する(既定値・上限・範囲外時 422 は hurl の検証範囲外のため本決定で規定する)。

## TBD-3 エラーレスポンスの形式

**決定:**

- エラーレスポンスの形式は `{"errors": {"<field>": ["<message>", ...]}}` とする。`<field>` は入力フィールド名またはリソース種別名(`token`、`article`、`profile`、`comment`、`credentials` 等)、値はメッセージ文字列の配列
- 422(バリデーションエラー)は必ずこの形式の body を返す
- 401 / 403 / 404 も同形式とする。body の省略は許容するが、`api/hurl/errors_*.hurl` が `$.errors.<key>[0]` をアサートするケースではそのキーを必ず含める(実質、401→`errors.token`、403/404→対象リソースのキーは必須)
- 409(重複)も同形式とし、`errors.<field>` に `"has already been taken"` を返す

**hurl との整合:** `errors_*.hurl` が 401→`$.errors.token[0] == "is missing"`、403→`$.errors.<resource>[0] == "forbidden"`、404→`$.errors.<resource>[0] == "not found"`、422→`$.errors.<field>[0] == "can't be blank"`、409→`"has already been taken"` をアサートするのと整合する。

## TBD-4 JWT の有効期限と署名鍵の扱い

**決定:**

- 署名アルゴリズムは HS256、有効期限は発行から 7 日とする
- 署名鍵は環境変数 `JWT_SECRET` から読む。鍵をリポジトリにコミットしない
- トークンは `user.token` として返し、保護されたエンドポイントでは `Authorization: Token <jwt>` ヘッダで送る(openapi.yml の securitySchemes と同じ)
- 期限切れ・署名不正・形式不正のトークンは 401 とし、エラー形式は TBD-3 に従う(`errors.token`)

**hurl との整合:** `auth.hurl` が登録・ログイン・`GET/PUT /user` の各レスポンスで `$.user.token isString` かつ非空をアサートし、capture したトークンを `Authorization: Token {{token}}` で使い回すのと整合する(署名方式・期限・鍵の管理は hurl の検証範囲外のため本決定で規定する)。

## openapi.yml との関係

本ファイルの決定と `api/openapi.yml` が矛盾・不一致する場合は、本ファイル(decisions.md)を正とする。具体的に openapi.yml を超えて規定した点:

- `limit` の上限 100 と範囲外値の 422(openapi.yml の `limitParam` は `minimum: 1` と `default: 20` のみで上限の規定なし)
- `offset` の既定値 0(openapi.yml の `offsetParam` は `default` の規定なし)
- JWT の署名方式・有効期限・鍵の管理(openapi.yml は「valid JWT token」と `Token` ヘッダ形式を規定するのみ)
- slug の生成規則・衝突時の扱い・非 ASCII の扱い(openapi.yml は `slug: type: string` のみ)
