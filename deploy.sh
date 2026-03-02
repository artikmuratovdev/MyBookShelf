#!/usr/bin/env bash
set -e

APP_NAME="mybookshelf"
REPO_URL="https://github.com/artikmuratovdev/MyBookShelf.git"
BRANCH="main"

APP_DIR="/var/www/${APP_NAME}"
VENV_DIR="${APP_DIR}/.venv"
SOCK_DIR="/run/${APP_NAME}"
SOCK_PATH="${SOCK_DIR}/${APP_NAME}.sock"

APP_USER="www-data"
APP_GROUP="www-data"

PUBLIC_IP="$(curl -s http://checkip.amazonaws.com)"

echo "Deploying ${APP_NAME} to IP ${PUBLIC_IP}"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo"
  exit 1
fi

apt update -y
apt install -y python3 python3-venv python3-pip git nginx curl

# ------------------------------------------------------------------

if [[ ! -d "${APP_DIR}" ]]; then
  git clone -b "${BRANCH}" "${REPO_URL}" "${APP_DIR}"
else
  git -C "${APP_DIR}" pull origin "${BRANCH}"
fi

chown -R ${APP_USER}:${APP_GROUP} "${APP_DIR}"

# ------------------------------------------------------------------

python3 -m venv "${VENV_DIR}"
source "${VENV_DIR}/bin/activate"
pip install --upgrade pip
pip install -r "${APP_DIR}/requirements.txt" gunicorn django-environ
deactivate

# ------------------------------------------------------------------
# ENV
cat > "${APP_DIR}/.env" << EOF
DEBUG=False
SECRET_KEY=$(python3 - <<PY
import secrets; print(secrets.token_urlsafe(50))
PY
)
ALLOWED_HOSTS=${PUBLIC_IP}
STATIC_ROOT=${APP_DIR}/staticfiles
MEDIA_ROOT=${APP_DIR}/media
EOF

chown ${APP_USER}:${APP_GROUP} "${APP_DIR}/.env"
chmod 640 "${APP_DIR}/.env"

# ------------------------------------------------------------------

sudo -u ${APP_USER} "${VENV_DIR}/bin/python" "${APP_DIR}/manage.py" migrate --noinput
sudo -u ${APP_USER} "${VENV_DIR}/bin/python" "${APP_DIR}/manage.py" collectstatic --noinput

mkdir -p "${SOCK_DIR}"
chown ${APP_USER}:${APP_GROUP} "${SOCK_DIR}"

# ------------------------------------------------------------------
# GUNICORN SERVICE
cat > /etc/systemd/system/${APP_NAME}.service << EOF
[Unit]
Description=Gunicorn for ${APP_NAME}
After=network.target

[Service]
User=${APP_USER}
Group=${APP_GROUP}
WorkingDirectory=${APP_DIR}
EnvironmentFile=${APP_DIR}/.env
ExecStart=${VENV_DIR}/bin/gunicorn \\
  --workers 3 \\
  --bind unix:${SOCK_PATH} \\
  config.wsgi:application
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart ${APP_NAME}
systemctl enable ${APP_NAME}

# ------------------------------------------------------------------
# NGINX
cat > /etc/nginx/sites-available/${APP_NAME} << EOF
server {
    listen 80;
    server_name _;

    location /static/ {
        alias ${APP_DIR}/staticfiles/;
    }

    location /media/ {
        alias ${APP_DIR}/media/;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:${SOCK_PATH};
    }
}
EOF

ln -sf /etc/nginx/sites-available/${APP_NAME} /etc/nginx/sites-enabled/${APP_NAME}
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx

echo "DONE → http://${PUBLIC_IP}"