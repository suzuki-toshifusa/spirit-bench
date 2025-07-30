#!/bin/bash
# Spirit: 総合的なカラム変更検証スクリプト（sysbenchテーブル用）

HOST=${MYSQL_HOST:-mysql}
PORT=${MYSQL_PORT:-3306}
USER=${MYSQL_USER:-testuser}
PASSWORD=${MYSQL_PASSWORD:-testpass}
DATABASE=${MYSQL_DATABASE:-testdb}
TABLE=${TABLE:-sbtest1}

echo "Spirit: 総合的なカラム変更検証を実行"
echo "Host: $HOST:$PORT, Database: $DATABASE, Table: $TABLE"
echo "18種類のスキーマ変更パターンを順次実行します"

# Spiritコマンド実行関数
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
    
    if [ $? -eq 0 ]; then
        echo "✓ $description - 完了"
        echo ""
    else
        echo "✗ $description - 失敗"
        echo ""
    fi
}

echo "==========================================="
echo "パターン別スキーマ変更検証テスト開始"
echo "==========================================="

# 1. 列の追加
execute_spirit "新しい列を追加" "ADD COLUMN new_col VARCHAR(100) DEFAULT 'default_value'" "1" "18"

# 2. 列の削除 
execute_spirit "追加した列を削除" "DROP COLUMN new_col" "2" "18"

# 3. 列の名前変更
execute_spirit "k列の名前をk_renamedに変更" "CHANGE COLUMN k k_renamed INTEGER NOT NULL DEFAULT 0" "3" "18"

# 4. 列の名前を元に戻す
execute_spirit "k_renamed列の名前をkに戻す" "CHANGE COLUMN k_renamed k INTEGER NOT NULL DEFAULT 0" "4" "18"

# 5. 列の並び順変更（cをidの後に移動）
execute_spirit "c列をid列の後に移動" "MODIFY COLUMN c INTEGER NOT NULL DEFAULT 0 AFTER id" "5" "18"

# 6. 列のデフォルト値変更
execute_spirit "k列のデフォルト値を999に変更" "ALTER COLUMN k SET DEFAULT 999" "6" "18"

# 7. VARCHAR列のサイズ拡張
execute_spirit "c列のサイズを120から200に拡張" "MODIFY COLUMN c VARCHAR(200) NOT NULL DEFAULT ''" "7" "18"

# 8. VARCHAR列のサイズ縮小
execute_spirit "c列のサイズを200から100に縮小" "MODIFY COLUMN c VARCHAR(100) NOT NULL DEFAULT ''" "8" "18"

# 9. 列のデフォルト値削除
execute_spirit "k列のデフォルト値を削除" "ALTER COLUMN k DROP DEFAULT" "9" "18"

# 10. 自動インクリメント値の変更
execute_spirit "AUTO_INCREMENT値を10000に設定" "AUTO_INCREMENT=10000" "10" "18"

# 11. 列をNULL許可に変更
execute_spirit "k列をNULL許可に変更" "MODIFY COLUMN k INTEGER NULL" "11" "18"

# 12. 列のNOT NULL化（デフォルト値あり）
execute_spirit "k列をNOT NULL化（デフォルト値500設定）" "MODIFY COLUMN k INTEGER NOT NULL DEFAULT 500" "12" "18"

# 13. 列をNULL許可に変更
execute_spirit "k列をNULL許可に変更" "MODIFY COLUMN k INTEGER NULL" "13" "18"

# 14. 列のNOT NULL化（デフォルト値なし）
execute_spirit "k列をNOT NULL化（デフォルト値500設定）" "MODIFY COLUMN k INTEGER NOT NULL" "14" "18"

# 15. 列のデータ型変更（INTEGERをBIGINTに）
execute_spirit "k列のデータ型をINTEGERからBIGINTに変更" "MODIFY COLUMN k BIGINT NOT NULL DEFAULT 500" "15" "18"

# 16. 列の追加
execute_spirit "新しいSET型の列を追加" "ADD COLUMN new_col SET('a1', 'b2', 'c3', 'd4', 'e5', 'f6', 'g7')" "16" "18"

# 17. SETのメンバー追加変更（バイト数の制限を超えない）
execute_spirit "バイト数の制限を超えないSETのメンバーを追加" "MODIFY COLUMN new_col SET('a1', 'b2', 'c3', 'd4', 'e5', 'f6', 'g7', 'h8')" "17" "18"

# 18. SETのメンバー追加変更（バイト数の制限を超える）
execute_spirit "バイト数の制限を超えるSETのメンバーを追加" "MODIFY COLUMN new_col SET('a1', 'b2', 'c3', 'd4', 'e5', 'f6', 'g7', 'h8', 'i9')" "18" "18"

echo "==========================================="
echo "🎉 18種類すべての検証テストが完了しました！"
echo "==========================================="
echo ""
echo "📋 実行した変更内容:"
echo "  1. 列の追加: new_col VARCHAR(100)"
echo "  2. 列の削除: new_col"
echo "  3. 列の名前変更: k → k_renamed"
echo "  4. 列の名前復元: k_renamed → k"
echo "  5. 列の並び順変更: k列をid列の後に移動"
echo "  6. デフォルト値変更: k列のデフォルト値を999に"
echo "  7. VARCHAR拡張: c列を120→200文字に拡張"
echo "  8. VARCHAR縮小: c列を200→100文字に縮小"
echo "  9. デフォルト値削除: k列のデフォルト値を削除"
echo " 10. AUTO_INCREMENT: 値を10000に設定"
echo " 11. NULL許可: k列をNULL許可に変更"
echo " 12. NOT NULL化: k列をNOT NULL（デフォルト500）に変更"
echo " 13. NULL許可: k列をNULL許可に変更"
echo " 14. NOT NULL化: k列をNOT NULL（デフォルトなし）に変更"
echo " 15. データ型変更: k列をINTEGER→BIGINTに変更"
echo " 16. 列の追加: new_col SET('a1', 'b2', 'c3', 'd4', 'e5', 'f6', 'g7')"
echo " 17. SETのメンバー追加: new_colに'h8'を追加"
echo " 18. SETのメンバー追加（制限超え）: new_colに'i9'を追加"
echo ""
echo "現在のテーブル構造を確認するには:"
echo "mysql -h $HOST -P $PORT -u $USER -p$PASSWORD $DATABASE -e 'DESCRIBE $TABLE;'"