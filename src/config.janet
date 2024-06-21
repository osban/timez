(import ./svgs)
(import ./http :prefix "")
(import ./actions :prefix "")
(import ./layout :prefix "")

(def- classes @{:button "px-3.5 pt-0.5 pb-1 bg-sky-600 text-white rounded-md"})

(defn config {:path "/config"} "Config user companies and projects" [req data]
  (let [companies (get-all "companies")
        projects  (get-all "projects")]
    (layout
      [:div {:class "p-4"}
        [:h2 {:class "text-2xl font-bold mb-3"} "Companies"]
        [:div {:class "mb-3"}
          [:button {:class (string "mr-3 " (classes :button))}
            [:a {:href "/company/create" :hx-boost "true"} "New Company"]]]
        [:div
          (if (> (length companies) 0)
            [:table
              [:thead {:class "text-left"}
                [:tr
                  [:th {:class "pl-3"} "Name"]
                  [:th ""]]]
              [:tbody
                (map (fn [company]
                  [:tr
                    [:td {:class "px-3"}
                      [:a {:href (string "/company/edit?id=" (company :id))} (company :name)]]
                    [:td
                      [:span {:class "cursor-pointer"
                              :title "delete"
                              :hx-post (string "/company/delete?id=" (company :id))
                              :hx-target "#body"
                              :hx-confirm (string "Are you sure you wish to delete " (company :name) "?")} svgs/cross-red]]])
                  companies)]]
            [:h5 {:class "text-lg font-bold"} "No company found"])]

        [:h2 {:class "text-2xl font-bold mb-3 mt-8"} "Projects"]
        [:div {:class "mb-3"}
          [:button {:class (string "mr-3 " (classes :button))}
            [:a {:href "/project/create" :hx-boost "true"} "New Project"]]]
        [:div
          (if (> (length projects) 0)
          [:table
            [:thead {:class "text-left"}
              [:tr
                [:th {:class "pl-3"} "Name"]
                [:th ""]]]
            [:tbody
              (map (fn [project]
                [:tr
                  [:td {:class "px-3"}
                    [:a {:href (string "/project/edit?id=" (project :id))} (project :name)]]
                  [:td
                    [:span {:class "cursor-pointer"
                            :title "delete"
                            :hx-post (string "/project/delete?id=" (project :id))
                            :hx-target "#body"
                            :hx-confirm (string "Are you sure you wish to delete " (project :name) "?")} svgs/cross-red]]])
                projects)]]
              [:h5 {:class "text-lg font-bold"} "No projects found"])]])))
