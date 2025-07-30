#!/bin/bash
# Spirit: インデックス追加削除テスト

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: 主キー処理を実行"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE" 
echo "変更内容: 主キーの削除、主キーの削除と追加"

# 主キーの削除と追加
echo "1/2: 主キーを削除して追加中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="DROP PRIMARY KEY, ADD PRIMARY KEY (k)"

if [ $? -eq 0 ]; then
  echo "✓ 主キーの追加が完了しました"
else
  echo "⚠ 主キーの追加に失敗しました"
  exit 1
fi

#  主キーの削除
echo "2/2: 主キーを削除中..."
spirit \
  --host=$HOST:$PORT \
  --username=$USER \
  --password=$PASSWORD \
  --database=$DATABASE \
  --table=$TABLE \
  --alter="DROP PRIMARY KEY"

if [ $? -eq 0 ]; then
  echo "✓ 主キーの削除が完了しました"
else
  echo "✗ 主キーの削除に失敗しました"
  echo "📝 基本のインデックス処理は完了しました"
fi

