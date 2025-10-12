#!/bin/sh
# Inisialisasi repository jika belum ada
if [ ! -d "/repo/.git" ]; then
  git clone $REPO_URL /repo
fi

cd /repo

# Konfigurasi Git dari variabel lingkungan
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

# Loop untuk auto commit dan push
while true; do
  # Buat perubahan dummy dengan timestamp hingga milidetik
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S.%3N")
  RANDOM_NUM=$((RANDOM % 1000)) # Nomor acak antara 0-999
  echo "Update at $TIMESTAMP | Random: $RANDOM_NUM" >> dummy.txt

  # Tambahkan data dummy tambahan ke file lain
  echo "Log entry at $TIMESTAMP | Counter: $RANDOM_NUM" >> log.txt

  # Stage semua perubahan (file baru, dihapus, atau dimodifikasi)
  git add .

  # Periksa apakah ada perubahan untuk di-commit
  if git status --porcelain | grep .; then
    # Commit perubahan
    git commit -m "Auto commit at $TIMESTAMP with random $RANDOM_NUM"
    # Push ke branch main
    git push origin main
  else
    echo "Tidak ada perubahan untuk di-commit pada $TIMESTAMP"
  fi

  # Tunggu sesuai interval
  sleep $COMMIT_INTERVAL
done
