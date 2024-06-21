(defn options [tabl & selected]
  (let [selected (first selected)]
    (map
      (fn [pair]
        (let [ops (if (= selected (pair 0))
                    {:value (pair 0) :selected ""}
                    {:value (pair 0)})]
          [:option ops (pair 1)]))
      (pairs tabl))))

(defn getdate []
  (let [sysdate (os/date (os/time) :local)
        prefix |(slice (string "0" $) -3)]
    (string (sysdate :year) "-" (prefix (+ (sysdate :month) 1)) "-" (prefix (+ (sysdate :month-day) 1)))))