#!/bin/bash
# Spirit: ALGORITHM=INSTANT 64回上限テスト
# ADD COLUMN/DROP COLUMNを65回実行して上限到達を検証

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: ALGORITHM=INSTANT 64回上限検証テスト"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE"
echo "ADD COLUMNを66回実行してINSTANT上限到達を確認します"
echo ""

# Spiritコマンド実行関数（modify-column.shを参考）
execute_spirit() {
    local description="$1"
    local alter_sql="$2"
    local step_num="$3"
    local total_steps="$4"
    
    echo "$step_num/$total_steps: $description"
    spirit \
        --host=$HOST:$PORT \
        --username=$USER \
        --password=$PASSWORD \
        --database=$DATABASE \
        --table=$TABLE \
        --alter="$alter_sql"
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "✓ $description - 完了"
        return 0
    else
        echo "✗ $description - 失敗 (終了コード: $exit_code)"
        return $exit_code
    fi
}

echo "==========================================="
echo "ALGORITHM=INSTANT上限検証テスト開始"
echo "==========================================="

# カウンター
success_count=0
failure_count=0

# 66回の操作を実行
for i in {1..66}; do
    column_name="test_instant_$(printf "%03d" $i)"
    operation_num=$((($i - 1) * 2 + 1))
    
    echo ""
    echo "--- 操作セット $i/66 ---"
    
    # ADD COLUMN実行
    execute_spirit "カラム追加: $column_name" "ADD COLUMN $column_name INT DEFAULT 0" "$operation_num" "66"

    if [ $? -eq 0 ]; then
        success_count=$((success_count + 1))
    else
        failure_count=$((failure_count + 1))
        echo ""
        echo "🎯 ADD COLUMNで上限に到達しました！"
        echo "成功した操作回数: $success_count 回"
        echo "失敗した操作回数: $failure_count 回"
        echo "予想: 64回目または65回目でINSTANT上限に到達"
        break
    fi
done

echo ""
echo "==========================================="
echo "テスト結果サマリー"
echo "==========================================="
echo "実行した操作セット数: $i/66"
echo "成功した操作回数: $success_count"
echo "失敗した操作回数: $failure_count"
echo "総操作回数: $((success_count + failure_count))"

if [ $success_count -ge 64 ]; then
    echo ""
    echo "🎉 予想通りALGORITHM=INSTANT上限(64回)付近で操作が失敗しました！"
    echo "MySQL 8.0のINSTANT DDL制限が確認できました。"
elif [ $failure_count -gt 0 ]; then
    echo ""
    echo "⚠️  予想より早く操作が失敗しました。"
    echo "実際の成功操作数: $success_count 回"
else
    echo ""
    echo "❓ 66回すべての操作が成功しました。環境設定を確認してください。"
fi

echo ""
echo "テスト完了。現在のテーブル構造:"
mysql -h $HOST -P $PORT -u $USER -p$PASSWORD $DATABASE -e "SHOW CREATE TABLE $TABLE\\G" 2>/dev/null || echo "テーブル構造の表示に失敗しました"