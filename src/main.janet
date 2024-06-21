(import spork/httpf)
(import ./db)
(import ./server :prefix "")
(import ./timez)
(import ./times)
(import ./invoices)
(import ./config)
(import ./companies)
(import ./projects)

(db/open)
(db/init)

(-> (server)
     add-bindings-as-routes
    (listen "0.0.0.0" 8000))

(db/close)