#!/bin/bash

# Папки и имена
INSTALL_DIR="$HOME/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
SCRIPT_FILE="pulvid.sh"
DESKTOP_FILE="pulvid.desktop"

echo "== Инсталация на PulVid =="
echo
echo "⏳ Проверка за зависимости..."

REQUIRED=("ffmpeg" "zenity" "xdg-open" "curl")
MISSING=()

for pkg in "${REQUIRED[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "❌ Липсва: $pkg"
        MISSING+=("$pkg")
    else
        echo "✅ Наличен: $pkg"
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "📦 Инсталиране на липсващи пакети: ${MISSING[*]}"
    sudo apt update
    sudo apt install -y "${MISSING[@]}"
fi

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
chmod 644 "$DESKTOP_DIR/$DESKTOP_FILE"
sed -i "s|Icon=pulvid-icon|Icon=$HOME/.local/share/icons/pulvid-icon.png|" "$DESKTOP_DIR/$DESKTOP_FILE"

# По избор: десктоп икона
read -p "🖥️ Искаш ли икона на десктопа? (y/n): " ANSWER
if [[ "$ANSWER" == "y" || "$ANSWER" == "Y" ]]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/"
    chmod +x "$HOME/Desktop/$DESKTOP_FILE"
    # Маркиране като доверен файл (за среди, поддържащи gio)
    if command -v gio >/dev/null 2>&1; then
        gio set "$HOME/Desktop/$DESKTOP_FILE" metadata::trusted true 2>/dev/null
    fi
    echo "✅ Икона е добавена на десктопа."
fi

# Опресняване на менюто
update-desktop-database "$DESKTOP_DIR"
if command -v lxpanelctl >/dev/null 2>&1; then
    lxpanelctl restart
fi

# Финално съобщение
echo
echo "✅ PulVid е инсталиран успешно!"
echo "🎬 Стартирай го от менюто или с двоен клик."
read -p "Натисни Enter за изход..."
