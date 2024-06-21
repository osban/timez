(import ./svgs)
(import spork/htmlgen)
(import ./http :prefix "")
(import ./actions :prefix "")
(import ./layout :prefix "")
(import ./utils :prefix "")
(import ./pdf :prefix "")

(def- classes @{:button "px-3.5 pt-0.5 pb-1 bg-sky-600 text-white rounded-md"})

(defn invoices {:path "/invoices"} "Invoices list" [req data]
  (let [invos    (get-all "invoices")
        projects (get-all "projects")
        curs {"USD" "$" "EUR" "€"}
        proj (fn [id] (find |(= (get $ :id) id) projects))]
    (layout
      [:div {:class "p-4"}
        [:h2 {:class "text-2xl font-bold mb-3"} "Invoices"]
        [:div
          (if (> (length invos) 0)
            [:table
              [:thead
                [:tr
                  (map
                    |[:th {:class "text-left px-3"} $]
                    ["date" "project" "total" ""])]]
              [:tbody
                (map (fn [invo]
                  [:tr
                    [:td {:class "px-3"} (invo :date)]
                    [:td {:class "px-3"} ((proj (invo :projid)) :name)]
                    [:td {:class "px-3"} (curs ((proj (invo :projid)) :currency)) (invo :total)]
                    [:td {:class "flex"}
                      [:span {:class "cursor-pointer mr-1.5 mt-1"
                              :title "pdf"
                              :hx-post (string "/invoices/pdf?id=" (invo :id))
                              :hx-target "#body"} svgs/pdf]
                      [:a {:class "cursor-pointer mt-0.5"
                           :title "preview"
                           :href (string "/invoices/preview?id=" (invo :id))} svgs/eye]
                      [:span {:class "cursor-pointer"
                              :title "delete"
                              :hx-post (string "/invoices/delete?id=" (invo :id))
                              :hx-target "#body"
                              :hx-confirm (string "Are you sure you wish to delete this invoice?")} svgs/cross-red]]])
                  invos)]]
            [:h5 {:class "text-lg font-bold"} "No invoices found"])]])))

(defn create-invo {:path "/invoices/create"} "Create invoice" [req data]
  (if (empty? data)
    (redirect-to "/times")
    (let [ids (sort-by scan-number (data "box"))
          times (string/join ids ",")]
      (var projid nil)
      (var total 0)
      (each id ids
        (let [time (get-id "times" (scan-number id))]
          (when (nil? projid)
            (set projid (time :projid)))
          (set total (+ total (time :total)))))
      (create "invoices" {:date (getdate) :projid projid :total total :times times} "/invoices"))))

(defn delete-invo {:path "/invoices/delete"} "Delete invoice" [req data]
  (delete "invoices" (scan-number ((parse-body (req :query-string)) :id)) "/invoices"))

(defn gethtml [id]
  (let [invo (get-id "invoices" id)
        proj (get-id "projects" (invo :projid))
        times (get-all "times")
        time (fn [id] (find |(= (get $ :id) id) times))
        time-ids (map scan-number (string/split "," (invo :times)))
        content @{:invo invo :comp @"" :proj proj :times @[]}]
    (each tid time-ids
      (array/push (content :times) (time tid))
      (when (empty? (content :comp)) (set (content :comp) (get-id "companies" ((time tid) :compid)))))
    {:date (invo :date) :name (proj :name) :html (template content)}))

(defn preview {:path "/invoices/preview"} "Preview invoice pdf" [req data]
  ((gethtml (scan-number ((parse-body (req :query-string)) :id))) :html))

(defn pdf {:path "/invoices/pdf"} "Create invoice pdf" [req data]
  (let [info (gethtml (scan-number ((parse-body (req :query-string)) :id)))
        filename (string (string/slice (string/replace-all "-" "" (info :date)) 2) "-" (string/replace-all " " "_" (info :name)))
        basedir ((parse-body (string/replace "\n" "" (slurp ".env"))) :DIR)
        html (do (spit (string filename ".html") (htmlgen/html (info :html))) "")
        res-pdf (os/execute @("wkhtmltopdf" (string filename ".html") (string filename ".pdf")) :p)
        res-mv (os/execute @("mv" (string filename ".pdf") (string basedir (string/slice (info :date) 0 4) "/" (string filename ".pdf"))) :p)
        res-rm (os/execute @("rm" (string filename ".html")) :p)]
    (redirect-to (string "/invoices/result?pdf=" res-pdf "&mv=" res-mv "&rm=" res-rm))))

(defn result {:path "/invoices/result"} "Show results" [req data]
  (let [res (parse-body (req :query-string))]
    (layout
      [:div {:class "p-4"}
        [:h2 {:class "text-2xl font-bold mb-3"} "Invoices"]
        [:div {:class "flex justify-between w-[140px]"} "pdf created: "
          (if (= (res :pdf) "0")
            svgs/check
            svgs/cross-red-sm)]
        [:div {:class "flex justify-between w-[140px]"} "pdf moved: "
          (if (= (res :mv) "0")
            svgs/check
            svgs/cross-red-sm)]
        [:div {:class "flex justify-between w-[140px]"} "html removed: "
          (if (= (res :rm) "0")
            svgs/check
            svgs/cross-red-sm)]
        [:div {:class "mt-3"}
          [:button {:class (string "mr-3 " (classes :button))}
            [:a {:href "/invoices" :hx-boost "true"} "OK"]]]])))