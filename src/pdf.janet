(import ./utils :prefix "")

(defn txt [field idx]
  (let [fields {
    "title" ["Invoice" "Factuur"]
    "coc" ["CoC: " "KvK: "]
    "vat" ["VAT: " "BTW: "]
    "nr" ["Invoice number: " "Factuurnummer: "]
    "date" ["Date" "Datum"]
    "description" ["Description" "Omschrijving"]
    "price" ["Price" "Prijs"]
    "hours" ["Hours" "Uren"]
    "total" ["Total" "Totaal"]
    "sub" ["Subtotal" "Subtotaal"]
    "tax" ["Tax "  "BTW "]}]
  ((fields field) idx)))

(defn template [{:invo invo :comp cmpy :proj proj :times times}]
  (let [idx (if (= (proj :language) "EN") 0 1)
        curs {"USD" "$" "EUR" "€"}
        calctax (fn [perc total] (/ (math/round (* (* (/ perc 100) total) 100)) 100))]
    @"<!DOCTYPE html>"
    [:html
      [:head
        [:title "Timez"]
        [:meta {:charset "utf-8"}]
        [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
        [:link {:href "http://osban.nl/timez/favicon.ico" :rel "icon" :type "image/x-icon"}]]
      [:body {:style "font-family:calibri,arial,verdana,sans-serif; font-size:18px; margin:0; padding:0"}
        [:div {:style "position:relative; width:100vw; height:100vh"}
          [:div {:style "width:970px; margin:0 auto; padding:20px"}
            [:div {:style "display:flex; justify-content:space-between; align-items:center"}
              [:div {:style "font-size: 2.25rem"} (txt "title" idx)]
              [:div {:style "margin-top:9px; font-size: 1rem; font-style:italic"} (invo :date)]]
            [:hr ""]
            [:div {:style "display:flex; justify-content:space-between; margin-top:20px"}
              [:div
                [:div {:style "font-weight:bold"} (proj :name)]
                [:div (proj :address)]
                [:div (proj :city)]
                [:div (proj :country)]]
              [:div {:style "margin-right:20px"}
                [:div {:style "font-weight:bold"} (cmpy :name)]
                [:div (cmpy :address)]
                [:div (cmpy :city)]
                [:div (cmpy :country)]
                [:div {:style "margin-top:3px"} (txt "coc" idx) (cmpy :coc)]
                [:div (txt "vat" idx) (cmpy :vat)]
                [:div "Bank: " (proj :bank)]]]
            [:div {:style "margin-top:90px"} (txt "nr" idx) (string/slice (string/replace-all "-" "" (invo :date)) 2)]
            [:div {:style "margin-top:60px"}
              [:table {:style "width:100%; text-align:left; font-size:18px"}
                [:thead
                  (map |[:th (txt $ idx)]
                    ["date" "description" "price" "hours" "total"])]
                [:tbody
                  (map |
                    [:tr {:style "height:28px"}
                      [:td {:style "width:120px"} ($ :date)]
                      [:td ($ :description)]
                      [:td (curs (proj :currency)) (string/format "%0.2f" ($ :price))]
                      [:td (string/format "%0.1f" ($ :hours))]
                      [:td {:style "width:100px"} (string (curs (proj :currency)) (string/format "%0.2f" ($ :total)))]]
                    times)
                  [:tr
                    [:td {:colspan "4"}]
                    [:td
                      [:hr ""]]]
                  [:tr
                    [:td {:colspan "3"}]
                    [:td {:style "padding-top:8px"} (txt "sub" idx)]
                    [:td (string (curs (proj :currency)) (string/format "%0.2f" (invo :total)))]]
                  [:tr
                    [:td {:colspan "3"}]
                    [:td {:style "padding-top:5px"} (txt "tax" idx) "(" (proj :tax) "%)"]
                    [:td (string (curs (proj :currency)) (string/format "%0.2f" (calctax (proj :tax) (invo :total))))]]
                  [:tr {:style "font-weight:bold"}
                    [:td {:colspan "3"}]
                    [:td {:style "padding-top:5px; font-size:18px; font-weight:bold"} (txt "total" idx)]
                    [:td (string (curs (proj :currency)) (string/format "%0.2f" (+ (invo :total) (calctax (proj :tax) (invo :total)))))]]]]]]]]]))

