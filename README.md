# PulVid (Lubuntu Edition)

Download videos in high quality with audio from any supported URL, with a simple graphical interface, resolution selector and optional MP4 conversion.  
Designed for **Linux (Lubuntu/XFCE)** environments and optimized for practical daily use on multiple machines.

## Features

- Paste any video URL (e.g. YouTube, Vimeo, etc.)
- Select from available resolutions (e.g. 720p, 1080p)
- Always includes audio – even when video-only formats are selected
- Adds resolution to the filename
- Automatically renames files if a name conflict occurs
- Optionally converts downloaded video to `.mp4` with a checkbox
- Uses **zenity GUI** for interaction – no terminal needed
- Displays buttons to open video or folder after download

## Requirements

Ensure the following packages are installed:

```bash
sudo apt install ffmpeg zenity curl xdg-utils
```

PulVid also requires the latest version of `yt-dlp`, which is automatically downloaded by the installer.

## Installation

1. **Download or clone the repository:**

```bash
git clone https://github.com/your-user/PulVid.git
cd PulVid
```

2. **Make the installation script executable and run it:**

```bash
chmod +x install_pulvid.sh
./install_pulvid.sh
```

The script will:
- Automatically install required tools (`yt-dlp`, `ffmpeg`, `zenity`, `curl`, `xdg-open`)
- Download the latest version of `yt-dlp` from GitHub
- Copy the main script to `~/bin/`
- Register a `.desktop` launcher so PulVid appears in the application menu
- Optionally add a desktop shortcut

## Output

- Videos are saved in your `~/Videos` folder  
  Example: `Funny Cats 720p.webm`, `Funny Cats 720p-1.webm`, etc.

- Already existing files are auto-renamed to avoid overwriting.

## Example usage

Launch PulVid from your application menu or desktop shortcut, paste a link, select resolution, and click through.  
If the MP4 checkbox is selected, an additional `.mp4` version will be generated.

## Ideal for

- Office computers running Lubuntu/XFCE
- Batch downloading videos with GUI ease
- Users who need guaranteed audio and high quality
- Those who dislike using `yt-dlp` from the terminal

## Download

Get the latest version from the [release](https://github.com/hmartinov/PulVid/releases) folder.

## Changelog

See full release history in the [CHANGELOG.md](./CHANGELOG.md) file.

## License

MIT License – free for personal and commercial use.

## Author

H. Martinov  
[hmartinov@dmail.ai](mailto:hmartinov@dmail.ai)  
[GitHub](https://github.com/hmartinov/PulVid)

---

_See update options directly in the app menu (in future versions)._
