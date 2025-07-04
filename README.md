# Spirit検証環境 - Docker構成

Online Schema Change Tool「Spirit」の検証環境をDockerで構築するための設定ファイル群です。

## 構成

- **MySQL 8.4**: メインのデータベースサーバー
- **sysbench**: データベースベンチマークツール
- **Spirit**: Online Schema Change Tool

## 環境変数設定

`.env`ファイルで全サービス共通の設定を管理しています：

```bash
# MySQL接続情報
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_DATABASE=testdb  
MYSQL_USER=testuser
MYSQL_PASSWORD=testpass

# Spirit設定
TABLE=test_table
```

設定を変更したい場合は`.env`ファイルを編集してください。

## 使用方法

### 1. 環境の起動

```bash
# 全サービスをバックグラウンドで起動
docker-compose up -d

# ログを確認
docker-compose logs -f
```

### 2. MySQLサーバーの確認

```bash
# MySQLに直接接続（環境変数を使用）
source .env && docker exec -it spirit-mysql mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# ホストから接続
mysql -h localhost -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE
```

### 3. sysbenchでの負荷テスト

```bash
# sysbenchコンテナに接続
docker exec -it spirit-sysbench /bin/bash

# MySQLに接続テスト（環境変数が自動設定されています）
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# テストデータの準備
cd /scripts
./prepare.sh

# ベンチマーク実行
./run.sh

# カスタム設定での実行例
TABLES=5 TABLE_SIZE=50000 THREADS=8 TIME=120 ./run.sh
```

### 4. Spiritでのスキーマ変更

```bash
# Spiritコンテナに接続
docker exec -it spirit-tool /bin/bash

# MySQLに接続テスト（環境変数が自動設定されています）
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# サンプルスクリプト実行
cd /scripts
./example.sh

# 直接Spiritコマンド実行例（環境変数を使用）
spirit --host=$MYSQL_HOST --username=$MYSQL_USER --password=$MYSQL_PASSWORD --database=$MYSQL_DATABASE \
       --table=$TABLE --alter="ADD COLUMN new_col VARCHAR(100)" --execute=false

# 実際のスキーマ変更実行
spirit --host=$MYSQL_HOST --username=$MYSQL_USER --password=$MYSQL_PASSWORD --database=$MYSQL_DATABASE \
       --table=$TABLE --alter="ADD COLUMN new_col VARCHAR(100)"
```

## 設定ファイル

### MySQL接続情報

接続情報は`.env`ファイルで管理されています：

- Host: `mysql` (コンテナ間通信) / `localhost:3306` (ホストから)
- Database: `testdb` (環境変数: `$MYSQL_DATABASE`)
- User: `testuser` (環境変数: `$MYSQL_USER`)
- Password: `testpass` (環境変数: `$MYSQL_PASSWORD`)
- Root Password: `rootpass` (環境変数: `$MYSQL_ROOT_PASSWORD`)

**注意**: コンテナ内では環境変数が自動設定されるため、スクリプト実行時は環境変数を使用してください。

### ディレクトリ構成
```
.
├── .env                        # 環境変数設定ファイル
├── docker-compose.yml          # Docker Composeメイン設定
├── Dockerfile.sysbench         # sysbench用Dockerfile
├── Dockerfile.spirit           # Spirit用Dockerfile
├── mysql-init/                 # MySQL初期化SQLファイル
├── sysbench-scripts/           # sysbenchスクリプト
└── spirit-scripts/             # Spiritサンプルスクリプト
```

## 注意事項

- sysbenchでの負荷テスト中にSpiritを実行することで、実際の本番環境に近い状況でのテストが可能です
- MySQL 8.4の新機能を活用したい場合は、適宜設定を調整してください

## 停止・クリーンアップ

```bash
# サービス停止
docker-compose down

# データも含めて完全削除
docker-compose down -v
docker system prune -f
```

## トラブルシューティング

### MySQLに接続できない場合
```bash
# MySQL コンテナのログを確認
docker-compose logs mysql

# ヘルスチェック状態を確認
docker-compose ps
```

### Spiritでエラーが発生する場合
```bash
# Spiritコンテナ内でMySQLに接続できるか確認
docker exec -it spirit-tool mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# 環境変数の確認
docker exec -it spirit-tool env | grep MYSQL
docker exec -it spirit-sysbench env | grep MYSQL
```

# スキーマ変更スクリプト

  1. add-column.sh - カラム追加

  - created_at: タイムスタンプ（作成日時）
  - status: ステータス管理用VARCHAR(20)
  - updated_at: 更新日時（自動更新）

  2. add-index.sh - インデックス追加

  - idx_k_c: 複合インデックス（k, c）
  - idx_status: ステータス用インデックス
  - idx_created_at: 作成日時用インデックス

  3. modify-column.sh - カラム変更

  - c: CHAR(120) → VARCHAR(150)に拡張
  - pad: CHAR(60) → CHAR(50)に縮小
  - k: NOT NULL制約とコメント追加

  使用方法

  ## sysbench負荷テスト実行中に別ターミナルで：

  ### カラム追加
  docker-compose exec spirit /scripts/add-column.sh

  ### インデックス追加
  docker-compose exec spirit /scripts/add-index.sh

  ### カラム変更
  docker-compose exec spirit /scripts/modify-column.sh

  ### 特定のテーブルを指定
  TABLE=sbtest2 docker-compose exec spirit /scripts/add-column.sh

  各スクリプトは実行権限付きで、エラーハンドリングと進捗表示機能が含まれています。