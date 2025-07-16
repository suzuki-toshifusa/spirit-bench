# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 言語設定
- 常に日本語で応答する
- すべてのコミュニケーションは日本語で行う

## プロジェクト概要
Online Schema Change Tool「Spirit」の検証環境をDockerで構築するためのプロジェクトです。
SpiritはGitHub社のgh-ostを再実装したツールで、MySQL 8.0以上でのスキーマ変更を高速化します。

## 環境構成
- **MySQL 8.4**: メインのデータベースサーバー
- **sysbench**: データベースベンチマークツール  
- **Spirit**: Online Schema Change Tool（Go製）
- **TiDB Tools**: データ比較・DDLチェック・データ生成ツール

## 開発用コマンド

### 環境起動・停止
```bash
# 全サービス起動
docker-compose up -d

# ログ確認
docker-compose logs -f

# 環境停止
docker-compose down

# データも含めて完全削除
docker-compose down -v && docker system prune -f
```

### データベース接続
```bash
# MySQLコンテナに直接接続
source .env && docker exec -it spirit-mysql mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# ホストから接続
mysql -h localhost -P 3306 -u testuser -ptestpass testdb
```

### sysbench負荷テスト
```bash
# sysbenchコンテナに接続
docker exec -it spirit-sysbench /bin/bash

# テストデータ準備
cd /scripts && ./prepare_100k.sh  # または ./prepare_1000k.sh

# ベンチマーク実行
./run.sh

# カスタム設定での実行
TABLES=5 TABLE_SIZE=50000 THREADS=8 TIME=120 ./run.sh
```

### Spiritスキーマ変更
```bash
# Spiritコンテナに接続
docker exec -it spirit-tool /bin/bash

# サンプルスクリプト実行
cd /scripts && ./example.sh

# 各種スキーマ変更スクリプト
./add-column.sh      # カラム追加
./add-index.sh       # インデックス追加  
./modify-column.sh   # カラム変更

# 直接Spiritコマンド実行
spirit --host=$MYSQL_HOST:$MYSQL_PORT --username=$MYSQL_USER --password=$MYSQL_PASSWORD --database=$MYSQL_DATABASE --table=$TABLE --alter="ADD COLUMN new_col VARCHAR(100)"
```

### Spirit (Go) 開発
```bash
# spirit-srcディレクトリで実行
cd spirit-src

# テスト実行
go test ./...

# 特定パッケージのテスト
go test ./pkg/migration

# ビルド
go build -o spirit cmd/spirit/main.go

# 実行
./spirit --help
```

## アーキテクチャ

### Spiritの主要コンポーネント
- **cmd/spirit/main.go**: メインエントリーポイント
- **pkg/migration/**: スキーマ変更の中核ロジック
- **pkg/check/**: 事前チェック機能
- **pkg/repl/**: レプリケーション監視
- **pkg/row/**: 行コピー処理
- **pkg/table/**: テーブル情報・チャンク処理
- **pkg/dbconn/**: データベース接続管理

### 環境変数設定
全サービス共通設定は`.env`ファイルで管理:
- `MYSQL_HOST=mysql`
- `MYSQL_PORT=3306`
- `MYSQL_ROOT_PASSWORD=rootpass`
- `MYSQL_DATABASE=testdb`
- `MYSQL_USER=testuser`  
- `MYSQL_PASSWORD=testpass`
- `TABLE=test_table`

## テスト実行
```bash
# Spiritのテスト実行
cd spirit-src && go test ./...

# 特定パッケージのテスト
go test ./pkg/migration -v

# 統合テスト（負荷テスト中にスキーマ変更）
# ターミナル1: sysbench実行
docker exec -it spirit-sysbench /scripts/run.sh

# ターミナル2: Spiritでスキーマ変更
docker exec -it spirit-tool /scripts/add-column.sh
```