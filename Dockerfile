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
RUN git clone https://github.com/yourusername/okr-management-system.git

# プロジェクトのディレクトリに移動
WORKDIR /var/www/html/okr-management-system

# .envファイルの作成と設定
COPY .env.example .env
RUN php artisan key:generate
RUN sed -i 's/DB_HOST=.*/DB_HOST=postgres/' .env
RUN sed -i 's/DB_DATABASE=.*/DB_DATABASE=myapp/' .env
RUN sed -i 's/DB_USERNAME=.*/DB_USERNAME=myappuser/' .env
RUN sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=myapppassword/' .env

# Composerパッケージのインストール
RUN composer install --no-dev --optimize-autoloader

# マイグレーション実行
RUN php artisan migrate --force

# コンテナ内でのポート設定
EXPOSE 8000

# コンテナ起動時に実行されるコマンド
CMD php artisan serve --host=0.0.0.0