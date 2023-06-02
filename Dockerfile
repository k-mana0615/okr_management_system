# ベースイメージを指定
FROM php:latest

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
WORKDIR /var/www/html

# OKR管理システムのソースコードをクローン
RUN git clone https://github.com/k-mana0615/okr_management_system.git

# プロジェクトのディレクトリに移動
WORKDIR /var/www/html/okr_management_system

# .envファイルの作成と設定
COPY .env.example .env
RUN php artisan key:generate

# .envファイルのセンシティブな情報を環境変数で置換する
ENV DB_HOST=postgres
ENV DB_DATABASE=myapp
ENV DB_USERNAME=myappuser
ENV DB_PASSWORD=myapppassword

# Composerパッケージのインストール
RUN composer install --no-dev --optimize-autoloader

# マイグレーション実行
RUN php artisan migrate --force

# コンテナ内でのポート設定
EXPOSE 8000

# コンテナ起動時に実行されるコマンド
CMD php artisan serve --host=0.0.0.0
