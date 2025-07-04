-- 初期化用SQL
-- データベースとユーザーの作成は環境変数で行われるため、ここでは基本的な設定のみ

-- Spiritで使用するテスト用のテーブル例
CREATE TABLE IF NOT EXISTS test_table (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_email (email)
);

-- sysbenchで使用するテーブル（sysbenchが自動作成するため、手動作成は不要）

-- Spiritテスト用のサンプルデータ
INSERT INTO test_table (name, email) VALUES 
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com'),
('Diana Prince', 'diana@example.com'),
('Eve Wilson', 'eve@example.com');

-- パフォーマンステスト用設定
-- SET GLOBAL innodb_buffer_pool_size = 256M;
-- SET GLOBAL innodb_log_file_size = 64M;