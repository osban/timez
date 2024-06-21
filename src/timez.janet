(import ./http :prefix "")

(defn home {:path "/"} "Homepage" [req data]
  (redirect-to "/times"))
