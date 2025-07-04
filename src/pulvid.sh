#!/bin/bash

VERSION="1.0"
REPO_URL="https://raw.githubusercontent.com/hmartinov/PulVid/main"
SCRIPT_URL="https://github.com/hmartinov/PulVid/releases/latest/download/pulvid.sh"
DESKTOP_URL="https://github.com/hmartinov/PulVid/releases/latest/download/pulvid.desktop"
SCRIPT_PATH="$HOME/bin/pulvid.sh"
DESKTOP_PATH="$HOME/.local/share/applications/pulvid.desktop"

# Проверка за нова версия
REMOTE_VERSION=$(curl -fs "$REPO_URL/version.txt" 2>/dev/null | tr -d '\r\n ')

version_is_newer() {
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do ver1[i]=0; done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do ver2[i]=0; done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if ((10#${ver2[i]} > 10#${ver1[i]})); then return 0; fi
        if ((10#${ver2[i]} < 10#${ver1[i]})); then return 1; fi
    done
    return 1
}

if [[ -n "$REMOTE_VERSION" ]] && version_is_newer "$VERSION" "$REMOTE_VERSION"; then
    zenity --question         --title="Налична е нова версия"         --text="Имате версия $VERSION.\nНалична е нова версия: $REMOTE_VERSION\n\nИскате ли да я изтеглите сега?"
    if [[ $? -eq 0 ]]; then
        TMPFILE=$(mktemp)
        if curl -fsSL "$SCRIPT_URL" -o "$TMPFILE"; then
            mv "$TMPFILE" "$SCRIPT_PATH"
            chmod +x "$SCRIPT_PATH"
            # Сваляне и на .desktop файла
            TMPDESKTOP=$(mktemp)
            if curl -fsSL "$DESKTOP_URL" -o "$TMPDESKTOP"; then
                mkdir -p "$(dirname "$DESKTOP_PATH")"
                mv "$TMPDESKTOP" "$DESKTOP_PATH"
                chmod +x "$DESKTOP_PATH"
            fi
            zenity --info --title="Обновено" --text="Скриптът беше обновен успешно до версия $REMOTE_VERSION."
            exec "$SCRIPT_PATH" "$@"
            exit 0
        else
            zenity --error --title="Грешка" --text="Неуспешно изтегляне на новата версия."
            rm -f "$TMPFILE"
        fi
    fi
fi

SAVE_DIR="$HOME/Videos"

for cmd in yt-dlp ffmpeg zenity xdg-open; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        zenity --error --text="Липсва зависимост: $cmd. Моля, инсталирай я."
        exit 1
    fi
done

# 1. Въвеждане на линк
URL=$(zenity --entry \
  --title="PulVid – Видео сваляне" \
  --text="Въведи линк към видеото:")

if [[ -z "$URL" ]]; then exit 1; fi

# 2. Чекбокс за конвертиране
zenity --question \
  --title="PulVid – Конвертиране" \
  --text="Искаш ли файлът да бъде конвертиран в .mp4 след изтеглянето?"
CONVERT_MP4=$?

# 3. Извличане на формати (показва се прогрес прозорец)
(
  echo "10"
  echo "# Извличане на наличните формати..."
  sleep 0.5
  yt-dlp -F "$URL" > /tmp/pulvid_formats.txt 2>/dev/null
  echo "100"
  sleep 0.5
) | zenity --progress --title="PulVid – Анализ на видео" --text="Моля, изчакай..." \
    --percentage=0 --auto-close --width=400

# 4. Избор на резолюция от комбинируеми видео формати
FORMAT_LIST=$(cat /tmp/pulvid_formats.txt | grep -E '^[0-9]+.*(mp4|webm)' | grep -v 'audio only' | grep -E '[0-9]{3,4}p')
if [[ -z "$FORMAT_LIST" ]]; then
    zenity --error --text="Не могат да бъдат извлечени налични формати."
    exit 1
fi

FORMATS=$(echo "$FORMAT_LIST" | awk '{printf "%s - %s\n", $1, $3}' | sort -u)
CHOICE=$(echo "$FORMATS" | zenity --list \
    --title="PulVid – Избор на резолюция" \
    --text="Избери качество за изтегляне:" \
    --column="Резолюции" \
    --height=300 --width=400)

VIDEO_ID=$(echo "$CHOICE" | awk '{print $1}')
RESOLUTION=$(echo "$CHOICE" | awk '{print $3}')
if [[ -z "$VIDEO_ID" || -z "$RESOLUTION" ]]; then exit 1; fi

# 5. Намиране на най-добро аудио
AUDIO_ID=$(cat /tmp/pulvid_formats.txt | grep 'audio only' | awk '{print $1}' | sort -n | head -n1)
if [[ -z "$AUDIO_ID" ]]; then
    zenity --error --text="Неуспешно намиране на аудио формат."
    exit 1
fi

# 6. Сваляне на видео + аудио (с обединяване)
TMPLOG=$(mktemp)
TMPFILE=$(mktemp)

(
  echo "0"
  echo "# Сваляне на видеото..."
  sleep 0.5

  yt-dlp -f "${VIDEO_ID}+${AUDIO_ID}" \
    -o "$SAVE_DIR/%(title)s ${RESOLUTION}.%(ext)s" \
    --print after_move:filepath "$URL" >"$TMPFILE" 2>"$TMPLOG"

  STATUS=$?
  echo "100"
  sleep 0.5
  exit $STATUS
) | zenity --progress \
    --title="PulVid – Изтегляне" \
    --text="Моля, изчакай..." \
    --width=400 \
    --height=100 \
    --percentage=0 \
    --auto-close

# 7. Обработка
if [[ $? -eq 0 ]]; then
    ORIGINAL_FILE=$(tail -n 1 "$TMPFILE")
    DIRPATH=$(dirname "$ORIGINAL_FILE")
    FILENAME=$(basename "$ORIGINAL_FILE")
    EXT="${FILENAME##*.}"
    BASENAME="${FILENAME%.*}"
    FINAL_FILE="$ORIGINAL_FILE"

    # Уникализиране, ако файлът съществува
    INDEX=1
    while [[ -e "$FINAL_FILE" ]]; do
        FINAL_FILE="$DIRPATH/${BASENAME}-$INDEX.$EXT"
        INDEX=$((INDEX + 1))
    done

    if [[ "$FINAL_FILE" != "$ORIGINAL_FILE" ]]; then
        mv "$ORIGINAL_FILE" "$FINAL_FILE"
    fi

    # 8. Конвертиране (ако е избрано и не е mp4)
    CREATED_MP4="no"
    MP4_FILE="$DIRPATH/${BASENAME}.mp4"
    if [[ "$CONVERT_MP4" == "0" && "$EXT" != "mp4" ]]; then
        ffmpeg -i "$FINAL_FILE" -c:v libx264 -c:a aac -y "$MP4_FILE"
        CREATED_MP4="yes"
    fi

    # 9. Финално меню
    OPTIONS=()
    OPTIONS+=("🎬 Пусни видеото")
    [[ "$CREATED_MP4" == "yes" ]] && OPTIONS+=("🎬 Пусни MP4 видеото")
    OPTIONS+=("📂 Отвори папката")

    CHOICE=$(zenity --list \
        --title="PulVid – Готово!" \
        --text="✅ Изтеглен файл:\n$FINAL_FILE" \
        --column="Действие" "${OPTIONS[@]}")

    case "$CHOICE" in
        "🎬 Пусни видеото")
            xdg-open "$FINAL_FILE"
            ;;
        "🎬 Пусни MP4 видеото")
            xdg-open "$MP4_FILE"
            ;;
        "📂 Отвори папката")
            xdg-open "$DIRPATH"
            ;;
    esac

else
    zenity --error --width=600 --height=400 \
           --title="⚠️ Грешка при изтегляне" \
           --text="Неуспешно изтегляне.\n\n$(head -n 20 "$TMPLOG")"
fi

rm -f "$TMPLOG" "$TMPFILE" /tmp/pulvid_formats.txt
