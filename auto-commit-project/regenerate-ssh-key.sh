#!/bin/bash
# Periksa apakah file setup.env ada
if [ ! -f "setup.env" ]; then
  echo "File setup.env tidak ditemukan. Pastikan file setup.env sudah dibuat."
  exit 1
fi

# Muat variabel dari setup.env
set -a
source setup.env
set +a

# Gunakan PROJECT_DIR dari setup.env, fallback ke 'project' jika tidak ada
PROJECT_DIR=${PROJECT_DIR:-project}

# Periksa apakah direktori ssh ada
if [ ! -d "$PROJECT_DIR/ssh" ]; then
  echo "Direktori $PROJECT_DIR/ssh tidak ditemukan. Membuat direktori..."
  mkdir -p "$PROJECT_DIR/ssh"
fi

# Periksa apakah file .env proyek ada
if [ ! -f "$PROJECT_DIR/.env" ]; then
  echo "File $PROJECT_DIR/.env tidak ditemukan. Pastikan proyek sudah diinisiasi."
  exit 1
fi

# Muat GIT_USER_EMAIL dari .env proyek
set -a
source "$PROJECT_DIR/.env"
set +a

# Gunakan GIT_USER_EMAIL dari .env proyek, fallback ke bot@example.com jika tidak ada
EMAIL=${GIT_USER_EMAIL:-bot@example.com}

# Hapus kunci SSH yang sudah ada
rm -f "$PROJECT_DIR/ssh/id_rsa" "$PROJECT_DIR/ssh/id_rsa.pub"

# Buat SSH key baru
ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f "$PROJECT_DIR/ssh/id_rsa" -N ""

# Set izin yang benar untuk SSH key
chmod 600 "$PROJECT_DIR/ssh/id_rsa"
chmod 644 "$PROJECT_DIR/ssh/id_rsa.pub"

# Tampilkan public key untuk ditambahkan ke GitHub/GitLab
echo "Kunci publik baru untuk ditambahkan ke GitHub/GitLab:"
cat "$PROJECT_DIR/ssh/id_rsa.pub"

# Catatan untuk pengguna
echo "Kunci SSH telah diregenerasi di $PROJECT_DIR/ssh."
echo "Tambahkan kunci publik di atas ke pengaturan SSH di GitHub/GitLab."
echo "Jika container sedang berjalan, restart dengan 'cd $PROJECT_DIR && podman-compose down && podman-compose up -d' untuk menggunakan kunci baru."