(import sqlite3 :as sql)
(import spork/path)
(import spork/sh)

(var db nil)

(def- schema
  `begin;

  create table if not exists times (
    id integer primary key,
    date text not null,
    hours integer default 0,
    price integer default 0,
    total integer default 0,
    projid integer,
    code text,
    compid integer,
    description text not null
  );

  create table if not exists invoices (
    id integer primary key,
    date text not null,
    projid integer,
    total integer default 0,
    times text not null
  );

  create table if not exists companies (
    id integer primary key,
    name text not null,
    address text,
    city text,
    country text,
    coc text,
    vat text default 0
  );

  create table if not exists projects (
    id integer primary key,
    name text not null,
    address text,
    city text,
    country text,
    bank text,
    currency text,
    tax integer default 0,
    language text
  );

   commit;`)

(defn db-path "Returns the runtime path of the database file" []
  (let [path "./src/data/timez.db"]
    (sh/create-dirs (path/posix/dirname path))
    path))

(defn query "Run SQL against DB" [sql &opt params]
  (if params
    (sql/eval db sql params)
    (sql/eval db sql)))

(defn open "Open DB" []
  (set db (sql/open (db-path)))
  (query "pragma foreign_keys = ON"))

(defn close "Close DB" []
  (sql/close db))

(defn init
  "Create initial database schema"
  []
  (query schema))

(defn last-insert-id
  "Get the ID of the last inserted record"
  []
  (sql/last-insert-rowid db))