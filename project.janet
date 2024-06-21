(declare-project
  :name "Timez"
  :description "Times and invoices"
  :dependencies ["https://github.com/janet-lang/spork"
                 "https://github.com/janet-lang/sqlite3"
                 "https://github.com/andrewchambers/janet-uri"]
  :author "Oscar Bannink"
  :license "Proprietary"
  :url  "https://osban.nl"
  :repo "https://osban.nl")

(declare-executable
  :name "timez"
  :entry "src/main.janet")
