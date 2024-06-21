(import spork/json)
(import ./svgs)
(import ./http :prefix "")
(import ./utils :prefix "")
(import ./actions :prefix "")
(import ./layout :prefix "")

(def- classes @{:button "px-3.5 pt-0.5 pb-1 bg-sky-600 text-white rounded-md"})

(defn times {:path "/times"} "Times list" [req data]
  (let [times    (get-all "times")
        projects (get-all "projects")
        curs {"USD" "$" "EUR" "€"}
        proj (fn [id] (find |(= (get $ :id) id) projects))
        attrs {:class "px-3"}]
    (layout
      [:div {:class "p-4"}
        [:h2 {:class "text-2xl font-bold mb-3"} "Times"]
        [:div {:class "mb-3"}
          [:button {:class (string "mr-3 " (classes :button))}
            [:a {:href "/times/create" :hx-boost "true"} "New Time"]]
          [:button {:class (string "mr-3 " (classes :button))
                    :hx-post "/times/json"
                    :hx-trigger "click"
                    :hx-target "#body"
                    :hx-include "[name=box]"}
            "Copy Json"]
          [:button {:class (string "mr-3 " (classes :button))
                    :hx-post "/invoices/create"
                    :hx-trigger "click"
                    :hx-target "#body"
                    :hx-include "[name=box]"}
            "Create Invoice"]]
        [:div
          (if (> (length times) 0)
            [:table
              [:thead
                [:tr
                  (map
                    |[:th {:class "text-left px-3"} $]
                    ["" "date" "project" "hours" "price" "total" "description" ""])]]
              [:tbody
                (map (fn [time]
                  [:tr {:class "hover:bg-slate-50"}
                    [:td
                      [:input {:type "checkbox" :name "box" :value (time :id)}]]
                      (map |
                        (cond
                          (= $ :projname)
                            [:td {:class "px-3"} ((proj (time :projid)) :name)]
                          (= $ :total)
                            [:td {:class "px-3"}
                              (string (curs ((proj (time :projid)) :currency)) (/ (math/round (* (* (time :hours) (time :price)) 100)) 100))]
                          [:td {:class "px-3"} (time $)])
                        [:date :projname :hours :price :total :description])
                    [:td {:class "flex"}
                      [:span {:class "cursor-pointer" :title "edit"}
                        [:a {:href (string "/times/edit?id=" (time :id))} svgs/edit]]
                      [:span {:class "cursor-pointer"
                              :title "copy"
                              :hx-post (string "/times/copy?id=" (time :id))
                              :hx-target "#body"} svgs/copy]
                      [:span {:class "cursor-pointer mt-0.5"
                              :title "delete"
                              :hx-post (string "/times/delete?id=" (time :id))
                              :hx-target "#body"
                              :hx-confirm (string "Are you sure you wish to delete this time entry?")} svgs/cross-red]]])
                  times)]]
            [:h5 {:class "text-lg font-bold"} "No time entries found"])]])))

(defn create-time {:path "/times/create"} "Create time entry" [req data]
  (let [companies (reduce (fn [a c] (put a (c :id) (c :name)) a) @{} (get-all "companies"))
        projects  (reduce (fn [a c] (put a (c :id) (c :name)) a) @{} (get-all "projects"))]
    (if (= (req :method) "GET")
      (layout
        [:div {:class "p-4"}
          [:h2 {:class "text-2xl font-bold mb-4"} "Create time entry"]
          [:form {:method "POST"
                  :action "/times/create"
                  :class "flex flex-col gap-[20px]"}
            (map |
              [:div {:class "flex"}
                [:label {:class "w-[100px] capitalize"}
                  (cond
                    (= $ "projid") "project"
                    (= $ "compid") "company"
                    $)]
                (cond
                  (= $ "date") [:input {:name $ :class "px-2" :type "date"}]
                  (= $ "projid") [:select {:name "projid" :style "padding:0 8px"} (options projects)]
                  (= $ "compid") [:select {:name "compid" :style "padding:0 8px"} (options companies)]
                  [:input {:name $ :class "px-2"}])]
              ["date" "description" "hours" "price" "code" "projid" "compid"])
            [:input {:type "submit" :value "Save" :class (string "w-[120px] " (classes :button))}]]])
      (create "times" (req :body) "/times"))))

(defn edit-time {:path "/times/edit"} "Edit time entry" [req data]
  (if (= (req :method) "GET")
    (let [companies (reduce (fn [a c] (put a (c :id) (c :name)) a) @{} (get-all "companies"))
          projects  (reduce (fn [a c] (put a (c :id) (c :name)) a) @{} (get-all "projects"))
          time (map-keys string (get-id "times" (scan-number ((parse-body (req :query-string)) :id))))]
      (if (nil? time)
        (redirect-to "/times")
        (layout
          [:div {:class "p-4"}
            [:h2 {:class "text-2xl font-bold mb-4"} "Edit time entry"]
            [:form {:method "POST"
                    :action "/times/edit"
                    :class "flex flex-col gap-[20px]"}
              [:input {:type "hidden" :name "id" :value (time "id")}]
              (map |
                [:div {:class "flex"}
                  [:label {:class "w-[100px] capitalize"}
                    (cond
                      (= $ "projid") "project"
                      (= $ "compid") "company"
                      $)]
                  (cond
                    (= $ "date") [:input {:name $ :value (time $) :class "px-2" :type "date"}]
                    (= $ "projid") [:select {:name "projid" :style "padding:0 8px"} (options projects (time $))]
                    (= $ "compid") [:select {:name "compid" :style "padding:0 8px"} (options companies (time $))]
                    [:input {:name $ :value (time $) :class "px-2"}])]
                ["date" "description" "hours" "price" "code" "projid" "compid"])
              [:input {:type "submit" :value "Save" :class (string "w-[120px] " (classes :button))}]
            ]])))
    (edit "times" (req :body) "/times")))

(defn delete-time {:path "/times/delete"} "Delete time entry" [req data]
  (delete "times" (scan-number ((parse-body (req :query-string)) :id)) "/times"))

(defn copy-time {:path "/times/copy"} "Copy time entry" [req data]
  (time-copy (scan-number ((parse-body (req :query-string)) :id))))

(defn times-json {:path "/times/json" :render-mime "text/html"} "Make json for copy/paste" [req data]
  (let [times (if (and (not (nil? data)) (has-key? data "box"))
          (map |(get-id "times" (scan-number $)) (sort (data "box")))
          @[])
        make (fn [arr]
          (reduce (fn [a c] (array/push a {:project (c :code) :who "Oscar Bannink" :comment (c :description) :hr (c :hours) :date (c :date)}) a) @[] arr))
        json (json/encode (make times) "  ")
        copy `navigator.clipboard.writeText(document.getElementById("json").innerHTML)`]
    (layout
      [:div {:class "p-4"}
        [:div
          [:button {
            :class (classes :button)
            :onclick copy} "Copy to Clipboard"]]
        [:div
          [:pre {:id "json"} json]]])))