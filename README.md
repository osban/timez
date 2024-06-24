# Timez
#### A program for time-keeping and creating pdf invoices, for personal use.

Used:
- language: Janet
- database: sqlite3
- css: Tailwind
- pdf creation: wkhtmltopdf (install before use)

Notes:
- server listens on port 8000
- database will be created in `/src/data`
- temp html and pdf will be created in `/src/files`
- pdf will be moved to a directory specified in an .env file in the root of the project, e.g. `DIR=/path/to/dir/`
- pdf will then be placed in a subdirectory with the year as name, e.g. `2024`
- make sure the directories exist
