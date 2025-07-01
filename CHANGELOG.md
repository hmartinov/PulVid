# Changelog

All notable changes to this project will be documented in this file.

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
