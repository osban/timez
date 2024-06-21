(import ./actions :prefix "")
(import ./http :prefix "")
(import ./layout :prefix "")

(def- classes @{:button "px-3.5 pt-0.5 pb-1 bg-sky-600 text-white rounded-md"})

(defn create-comp {:path "/company/create"} "Create company" [req data]
  (if (= (req :method) "GET")
    (layout
      [:div {:class "p-4"}
        [:h2 {:class "text-2xl font-bold mb-4"} "Create Company"]
        [:form {:method "POST"
                :action "/company/create"
                :class "flex flex-col gap-[20px]"}
          (map |
            [:div {:class "flex"}
              [:label {:class "w-[100px] capitalize"}
                (cond
                  (= $ "coc") "CoC/KvK"
                  (= $ "vat") "VAT/BTW"
                  $)]
              [:input {:name $ :class "px-2"}]]
            ["name" "address" "city" "country" "coc" "vat"])
          [:input {:type "submit" :value "Save" :class (string "w-[120px] " (classes :button))}]
        ]])
    (create "companies" (req :body) "/config")))

(defn edit-comp {:path "/company/edit"} "Edit company" [req data]
  (if (= (req :method) "GET")
    (let [company (map-keys string (get-id "companies" (scan-number ((parse-body (req :query-string)) :id))))]
      (if (nil? company)
        (redirect-to "/config")
        (layout
          [:div {:class "p-4"}
            [:h2 {:class "text-2xl font-bold mb-4"} "Edit Company"]
            [:form {:method "POST"
                    :action "/company/edit"
                    :class "flex flex-col gap-[20px]"}
              [:input {:type "hidden" :name "id" :value (company "id")}]
              (map |
                [:div {:class "flex"}
                  [:label {:class "w-[100px] capitalize"}
                    (cond
                      (= $ "coc") "CoC/KvK"
                      (= $ "vat") "VAT/BTW"
                      $)]
                  [:input {:name $ :value (company $) :class "px-2"}]]
                ["name" "address" "city" "country" "coc" "vat"])
              [:input {:type "submit" :value "Save" :class (string "w-[120px] " (classes :button))}]
            ]])))
    (edit "companies" (req :body) "/config")))

(defn delete-comp {:path "/company/delete"} "Delete company" [req data]
  (delete "companies" (scan-number ((parse-body (req :query-string)) :id)) "/config"))