(import ./http :prefix "")
(import ./utils :prefix "")
(import ./actions :prefix "")
(import ./layout :prefix "")

(def- classes @{:button "px-3.5 pt-0.5 pb-1 bg-sky-600 text-white rounded-md"})

(defn create-proj {:path "/project/create"} "Create project" [req data]
  (if (= (req :method) "GET")
    (layout
      [:div {:class "p-4"}
        [:h2 {:class "text-2xl font-bold mb-4"} "Create Project"]
        [:form {:method "POST"
                :action "/project/create"
                :class "flex flex-col gap-[20px]"}
          (map |
            [:div {:class "flex"}
              [:label {:class "w-[100px] capitalize"} $]
              (cond
                (= $ "currency") [:select {:name "currency" :style "padding:0 8px"} (options {"USD" "USD" "EUR" "EUR"})]
                (= $ "language") [:select {:name "language" :style "padding:0 8px"} (options {"EN" "English" "NL" "Nederlands"})]
                [:input {:name $ :class "px-2"}])]
            ["name" "address" "city" "country" "bank" "currency" "tax" "language"])
          [:input {:type "submit" :value "Save" :class (string "w-[120px] " (classes :button))}]]])
    (create "projects" (req :body) "/config")))

(defn edit-proj {:path "/project/edit"} "Edit project" [req data]
  (if (= (req :method) "GET")
    (let [project (map-keys string (get-id "projects" (scan-number ((parse-body (req :query-string)) :id))))]
      (if (nil? project)
        (redirect-to "/config")
        (layout
          [:div {:class "p-4"}
            [:h2 {:class "text-2xl font-bold mb-4"} "Edit Project"]
            [:form {:method "POST"
                    :action "/project/edit"
                    :class "flex flex-col gap-[20px]"}
              [:input {:type "hidden" :name "id" :value (project "id")}]
              (map |
                [:div {:class "flex"}
                  [:label {:class "w-[100px] capitalize"} $]
                  (cond
                    (= $ "currency") [:select {:name "currency" :style "padding:0 8px"} (options {"USD" "USD" "EUR" "EUR"} (project $))]
                    (= $ "language") [:select {:name "language" :style "padding:0 8px"} (options {"EN" "English" "NL" "Nederlands"} (project $))]
                    [:input {:name $ :value (project $) :class "px-2"}])]
                ["name" "address" "city" "country" "bank" "currency" "tax" "language"])
              [:input {:type "submit" :value "Save" :class (string "w-[120px] " (classes :button))}]
            ]])))
    (edit "projects" (req :body) "/config")))

(defn delete-proj {:path "/project/delete"} "Delete project" [req data]
  (delete "projects" (scan-number ((parse-body (req :query-string)) :id)) "/config"))