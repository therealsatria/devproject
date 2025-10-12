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

# Fungsi untuk regenerasi SSH key
regenerate_ssh_key() {
  # Periksa apakah direktori ssh ada
  if [ ! -d "$PROJECT_DIR/ssh" ]; then
    echo "Direktori $PROJECT_DIR/ssh tidak ditemukan. Membuat direktori..."
    mkdir -p "$PROJECT_DIR/ssh"
  fi

  # Gunakan GIT_USER_EMAIL dari setup.env, fallback ke bot@example.com jika tidak ada
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
}

# Buat direktori utama proyek berdasarkan PROJECT_DIR
mkdir -p "$PROJECT_DIR"/{repo,scripts,ssh}

# Buat file .env untuk proyek
cat <<EOL > "$PROJECT_DIR/.env"
# URL repository
REPO_URL=$REPO_URL

# Interval commit dalam detik
COMMIT_INTERVAL=$COMMIT_INTERVAL

# Konfigurasi Git
GIT_USER_NAME=$GIT_USER_NAME
GIT_USER_EMAIL=$GIT_USER_EMAIL
EOL

# Buat file docker-compose.yml
cat <<EOL > "$PROJECT_DIR/docker-compose.yml"
version: '3.8'
services:
  git-auto-commit:
    image: alpine/git
    volumes:
      - ./repo:/repo
      - ./scripts:/scripts
      - ./ssh:/root/.ssh
    env_file:
      - .env
    entrypoint: ["/bin/sh"]
    command: ["/scripts/auto-commit.sh"]
EOL

# Buat file auto-commit.sh dengan data dummy
cat <<EOL > "$PROJECT_DIR/scripts/auto-commit.sh"
#!/bin/sh
# Inisialisasi repository jika belum ada
if [ ! -d "/repo/.git" ]; then
  git clone \$REPO_URL /repo
fi

cd /repo

# Konfigurasi Git dari variabel lingkungan
git config user.name "\$GIT_USER_NAME"
git config user.email "\$GIT_USER_EMAIL"

# Loop untuk auto commit dan push
while true; do
  # Buat perubahan dummy dengan timestamp hingga milidetik
  TIMESTAMP=\$(date +"%Y-%m-%d %H:%M:%S.%3N")
  RANDOM_NUM=\$((RANDOM % 1000)) # Nomor acak antara 0-999
  echo "Update at \$TIMESTAMP | Random: \$RANDOM_NUM" >> dummy.txt

  # Tambahkan data dummy tambahan ke file lain
  echo "Log entry at \$TIMESTAMP | Counter: \$RANDOM_NUM" >> log.txt

  # Tambahkan perubahan ke Git
  git add dummy.txt log.txt
  git commit -m "Auto commit at \$TIMESTAMP with random \$RANDOM_NUM"
  git push origin main

  # Tunggu sesuai interval
  sleep \$COMMIT_INTERVAL
done
EOL

# Berikan izin eksekusi pada auto-commit.sh
chmod +x "$PROJECT_DIR/scripts/auto-commit.sh"

# Tambahkan konfigurasi SSH untuk GitHub/GitLab
cat <<EOL > "$PROJECT_DIR/ssh/config"
Host github.com
  HostName github.com
  User git
  IdentityFile /root/.ssh/id_rsa
  StrictHostKeyChecking no

Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile /root/.ssh/id_rsa
  StrictHostKeyChecking no
EOL

# Set izin untuk file config SSH
chmod 600 "$PROJECT_DIR/ssh/config"

# Panggil fungsi untuk membuat/meregenerasi SSH key
regenerate_ssh_key

# Tampilkan struktur direktori yang dibuat
echo "Struktur direktori yang dibuat di $PROJECT_DIR:"
tree "$PROJECT_DIR" || find "$PROJECT_DIR" -print

# Catatan untuk pengguna
echo "Proyek telah diinisiasi di $PROJECT_DIR. Tambahkan kunci publik di atas ke pengaturan SSH di GitHub/GitLab."
echo "Untuk meregenerasi kunci SSH di masa depan, edit GIT_USER_EMAIL di $PROJECT_DIR/.env (jika perlu), lalu jalankan:"
echo "  source setup-project.sh && regenerate_ssh_key"
echo "Jalankan 'cd $PROJECT_DIR && podman-compose up -d' untuk memulai otomasi."
