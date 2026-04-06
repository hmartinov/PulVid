# Changelog

All notable changes to this project will be documented in this file.

---

## [1.1] – 2026-04-06

### Fixed:
- Icon URL corrected – was pointing to the wrong repository (PDF-to-JPG instead of PulVid)
- Download exit code now captured correctly – previously yt-dlp errors were masked by zenity's exit code
- File renaming logic fixed – files were always renamed to filename-1.ext even when no conflict existed
- FFmpeg conversion result is now checked – success was assumed regardless of whether conversion succeeded
- apt update now runs only once – previously called separately for each missing dependency
- .desktop file in ~/.local/share/applications/ no longer marked as executable (chmod 644)
- Desktop shortcut now marked as trusted via gio set for proper behavior in Lubuntu/LXDE
- Exec path in pulvid.desktop updated to use bash -c with $HOME expansion for reliable launching

---

## [1.0] – 2024-07-01
### Initial release
### Added
- GUI video downloader with resolution selector
- Always includes audio (video+audio merging when needed)
- Adds resolution to filename
- Auto-renames files if duplicates exist (e.g. -1, -2)
- Optional MP4 conversion via checkbox
- Final prompt with buttons to play video or open folder
- Progress dialogs for format detection and download
- Smart handling of video+audio formats via yt-dlp

### Fixed
- Ensured downloaded videos always have audio
- Improved feedback and error messages
