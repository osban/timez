(import ./http :prefix "")
(import ./db)

# convert to number
(def nr-fields [:id :compid :projid :hours :price :tax])
(defn numberify [tabl]
  (reduce
    (fn [a c]
      (if (has-value? nr-fields (get c 0))
        (put a (c 0) (scan-number (c 1)))
        (put a (c 0) (c 1))) a)
    @{}
    (pairs tabl)))

# GET
(defn get-all "Get all from table" [tablename &opt order dir]
  (default order "id")
  (default dir "desc")
  (db/query (string "select * from " tablename " order by " order " " dir)))

(defn get-id "Get record by id" [tablename id]
  (get
    (db/query (string "select * from " tablename " where id = :id") {:id id}) 0))

# CREATE
(defn create [tablename rawdata redir]
  (let [data (if (= tablename "invoices") rawdata (numberify (parse-body rawdata)))
        times (do (when (= tablename "times") (set (data :total) (/ (math/round (* (* (data :hours) (data :price)) 100)) 100))) "")
        fields (string/join (keys data) ", ")
        vals (string/join (reduce (fn [a c] (array/push a (string ":" c)) a) @[] (keys data)) ", ")
        sql (string "insert into " tablename " (" fields ") values (" vals ")")]
    (db/query sql data)
    (redirect-to redir)))

# EDIT
(defn edit [tablename rawdata redir]
  (let [data (if (= tablename "invoices") rawdata (numberify (parse-body rawdata)))
        times (do (when (= tablename "times") (set (data :total) (/ (math/round (* (* (data :hours) (data :price)) 100)) 100))) "")
        sets (string/join (reduce (fn [a c] (array/push a (string c " = :" c)) a) @[] (keys data)) ", ")
        sql (string "update " tablename " set " sets " where id = :id")]
    (pp sql)
    (db/query sql data)
    (redirect-to redir)))

# DELETE
(defn delete "Delete record" [tablename id redir]
  (db/query (string "delete from " tablename " where id = :id") {:id id})
  (redirect-to redir))

# times: copy record
(defn time-copy "Copy time entry" [id]
  (let [time (merge (get-id "times" id))
        remid (do (set (time :id) nil) "")
        fields (string/join (keys time) ", ")
        vals (string/join (reduce (fn [a c] (array/push a (string ":" c)) a) @[] (keys time)) ", ")
        sql (string "insert into times (" fields ") values (" vals ")")]
    (db/query sql time)
  (redirect-to "/times")))
