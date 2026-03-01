#!/bin/bash
# Запускать на сервере (Ubuntu 20.04) от root.
# Предполагается, что проект уже скопирован в /opt/stocks_products (или задать APP_DIR).

set -e
APP_DIR="${APP_DIR:-/opt/stocks_products}"
cd "$APP_DIR"

echo "=== Установка пакетов ==="
apt-get update
apt-get install -y python3-pip python3-venv python3-dev libpq-dev nginx postgresql

echo "=== Создание БД и пользователя PostgreSQL ==="
sudo -u postgres psql -c "CREATE USER stocks WITH PASSWORD 'stocks_secret';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE netology_stocks_products OWNER stocks;" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE netology_stocks_products TO stocks;"

echo "=== Python venv и зависимости ==="
python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

echo "=== Переменные окружения ==="
if [ ! -f .env ]; then
    cat > .env << 'ENVFILE'
DJANGO_SECRET_KEY=change-me-to-random-secret
DJANGO_DEBUG=0
DJANGO_ALLOWED_HOSTS=*
DB_NAME=netology_stocks_products
DB_USER=stocks
DB_PASSWORD=stocks_secret
DB_HOST=127.0.0.1
DB_PORT=5432
ENVFILE
    echo "Создан .env — при необходимости отредактируйте SECRET_KEY и ALLOWED_HOSTS."
fi
[ -f .env ] && export $(grep -v '^#' .env | xargs)

echo "=== Миграции и статика ==="
./venv/bin/python manage.py migrate --noinput
./venv/bin/python manage.py collectstatic --noinput

echo "=== Nginx ==="
cp deploy/nginx.conf /etc/nginx/sites-available/stocks_products
ln -sf /etc/nginx/sites-available/stocks_products /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "=== Systemd сервис Gunicorn ==="
cp deploy/stocks_products.service /etc/systemd/system/
sed -i "s|/opt/stocks_products|$APP_DIR|g" /etc/systemd/system/stocks_products.service
systemctl daemon-reload
systemctl enable stocks_products
systemctl restart stocks_products

echo "=== Готово. Приложение: http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP')/ ==="
