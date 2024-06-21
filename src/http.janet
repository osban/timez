(import uri)

(defn map-keys
  `Executes a function on a dictionary's keys and returns a struct
   Example
   (map-keys snake-case {:created_at "" :uploaded_by ""}) -> {:created-at "" :uploaded-by ""}
  `
  [f dict]
  (let [acc @{}]
    (loop [[k v] :pairs dict]
      (put acc (f k) v))
    acc))

(defn redirect-to [path &opt extra-headers]
  {:status 302
   :headers (merge @{"Location" path} (or extra-headers {}))})

(defn- indexed-param? [str]
  (string/has-suffix? "[]" str))

(defn- body-table [all-pairs]
  (var output @{})
  (loop [[k v] :in all-pairs]
    (let [k (uri/unescape k)
          v (uri/unescape v)]
      (cond
        (indexed-param? k) (let [k (string/replace "[]" "" k)]
                             (if (output k)
                               (update output k array/concat v)
                               (put output k @[v])))
        :else (put output k v))))
  output)

(defn parse-body [str]
  (when (or (string? str)
            (buffer? str))
    (as-> (string/replace-all "+" "%20" str) ?
          (string/split "&" ?)
          (filter |(not (empty? $)) ?)
          (map |(string/split "=" $) ?)
          (body-table ?)
          (map-keys keyword ?))))

(defn format-qs [data]
  (let [parts (pairs data)]
    (string/join
     (map (fn [[k v]]
            (string (uri/escape (string k)) "=" (uri/escape (string v))))
          parts)
     "&")))
