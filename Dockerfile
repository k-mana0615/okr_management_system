# ビルドステージの定義
FROM php:latest AS builder

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Composerのインストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Laravelのインストール
RUN composer global require laravel/installer

# アプリケーションのディレクトリを作成
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# Laravelのソースコードをクローン
RUN composer create-project --prefer-dist laravel/laravel:^8.0 .

# SSHキーをコピー
COPY git_hub_ssh /root/.ssh/git_hub_ssh
COPY git_hub_ssh.pub /root/.ssh/git_hub_ssh.pub

# ホストキーの検証をスキップする設定
RUN mkdir -p -m 0600 /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts

# OKR管理システムのソースコードをクローン
RUN --mount=type=ssh git clone git@github.com:k-mana0615/okr_management_system.git

# .envファイルの作成と設定
COPY .env.example .env

# Composerパッケージのインストール
RUN composer install --no-dev --optimize-autoloader

# マイグレーション実行
RUN php artisan key:generate && php artisan migrate --force

# ベースイメージの指定
FROM php:latest

# ビルドステージから必要なファイルをコピー
COPY --from=builder /var/www/html /var/www/html

# .envファイルのセンシティブな情報を環境変数で置換する
ENV DB_HOST=postgres
ENV DB_DATABASE=myapp
ENV DB_USERNAME=myappuser
ENV DB_PASSWORD=myapppassword

# コンテナ内でのポート設定
EXPOSE 8000

# コンテナ起動時に実行されるコマンド
CMD php artisan serve --host=0.0.0.0
