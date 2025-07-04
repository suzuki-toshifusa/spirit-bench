#!/bin/bash
# Spirit: カラム変更スクリプト（sysbenchテーブル用）

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: カラム変更を実行"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE"
echo "変更内容: cカラムの拡張、padカラムの縮小、kカラムにNOT NULL制約追加"

# cカラムのサイズ拡張 (CHAR(120) -> VARCHAR(150))
echo "1/3: cカラムをCHAR(120)からVARCHAR(150)に変更中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="MODIFY COLUMN c VARCHAR(150) NOT NULL DEFAULT ''" \
  --execute

if [ $? -eq 0 ]; then
  echo "✓ cカラムの変更が完了しました"
else
  echo "✗ cカラムの変更に失敗しました"
  exit 1
fi

# padカラムのサイズ縮小 (CHAR(60) -> CHAR(50))
echo "2/3: padカラムをCHAR(60)からCHAR(50)に変更中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="MODIFY COLUMN pad CHAR(50) NOT NULL DEFAULT ''" \
  --execute

if [ $? -eq 0 ]; then
  echo "✓ padカラムの変更が完了しました"
else
  echo "✗ padカラムの変更に失敗しました"
  exit 1
fi

# kカラムにNOT NULL制約とコメント追加
echo "3/3: kカラムにNOT NULL制約とコメントを追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="MODIFY COLUMN k INTEGER NOT NULL DEFAULT 0 COMMENT 'Secondary index key'" \
  --execute

if [ $? -eq 0 ]; then
  echo "✓ kカラムの変更が完了しました"
  echo "🎉 すべてのカラム変更が完了しました！"
else
  echo "✗ kカラムの変更に失敗しました"
  exit 1
fi

echo ""
echo "📋 変更内容の確認:"
echo "  - c: CHAR(120) → VARCHAR(150)"
echo "  - pad: CHAR(60) → CHAR(50)"
echo "  - k: INTEGER DEFAULT 0 → INTEGER NOT NULL DEFAULT 0 COMMENT 'Secondary index key'"