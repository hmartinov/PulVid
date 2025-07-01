#!/bin/bash

# Папки и имена
INSTALL_DIR="$HOME/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
SCRIPT_FILE="pulvid.sh"
DESKTOP_FILE="pulvid.desktop"

echo "== Инсталация на PulVid =="
echo

# Инсталиране на зависимости
echo "⏳ Проверка за зависимости..."

REQUIRED=("ffmpeg" "zenity" "xdg-open" "curl")
for pkg in "${REQUIRED[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "📦 Липсва: $pkg – ще бъде инсталиран..."
        sudo apt update
        sudo apt install -y "$pkg"
    else
        echo "✅ Наличен: $pkg"
    fi
done

# Инсталиране на последна версия на yt-dlp
echo
echo "⬇️ Инсталиране на най-новата версия на yt-dlp..."
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
echo "✅ yt-dlp е обновен до последна версия"

# Копиране на файловете
echo
echo "📂 Копиране на файловете..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"

cp "$SCRIPT_FILE" "$INSTALL_DIR/"
cp "$DESKTOP_FILE" "$DESKTOP_DIR/"

chmod +x "$INSTALL_DIR/$SCRIPT_FILE"
chmod +x "$DESKTOP_DIR/$DESKTOP_FILE"

# По избор: десктоп икона
read -p "🖥️ Искаш ли икона на десктопа? (y/n): " ANSWER
if [[ "$ANSWER" == "y" || "$ANSWER" == "Y" ]]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/"
    chmod +x "$HOME/Desktop/$DESKTOP_FILE"
    echo "✅ Икона е добавена на десктопа."
fi

# Финално съобщение
echo
echo "✅ PulVid е инсталиран успешно!"
echo "🎬 Стартирай го от менюто или с двоен клик."
read -p "Натисни Enter за изход..."
