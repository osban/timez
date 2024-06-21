(defn layout [content]
  @"<!DOCTYPE html>"
  [:html {:lang "en" :class "bg-stone-100"}
    [:head
      [:title "Timez"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:link {:href "http://osban.nl/timez/favicon.ico" :rel "icon" :type "image/x-icon"}]
      [:link {:href "http://osban.nl/timez/compiled.css" :rel "stylesheet"}]
      [:script {:src "http://osban.nl/timez/htmx.min.js" :defer ""}]
    ]
    [:body {:id "body" :hx-replace-url "true" :hx-push-url "true"}
      [:div {:class "relative w-screen h-screen"}
        [:div {:class "container mx-auto bg-sky-300"}
          [:div {:class "text-center py-4"}
            [:h1 {:class "text-3xl font-bold tracking-widest"} "Timez"]
          ]
          [:div {:class "bg-sky-950"}
            [:ul {:class "flex justify-start items-center gap-14 ml-14 pt-3 pb-3.5 list-none"}
              [:li {:class "inline-block text-white cursor-pointer"}
                [:a {:href "/times" :hx-boost "true"} "Times"]]
              [:li {:class "inline-block text-white cursor-pointer"}
                [:a {:href "/invoices" :hx-boost "true"} "Invoices"]]
              [:li {:class "inline-block text-white cursor-pointer"}
                [:a {:href "/config" :hx-boost "true"} "Config"]]
            ]
          ]
          [:div {:class "bg-stone-100" :id "content"} content]
        ]
      ]
    ]
  ]
)