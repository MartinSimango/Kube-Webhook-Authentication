package main

import (
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/MartinSimango/Kube-Webhook-Authentication/authenticate"
	goenvloader "github.com/MartinSimango/go-envloader"
)

func main() {

	serverCrt := "${SERVER_CERT,./certs/server.crt}"
	serverKey := "${SERVER_KEY,./certs/server.key}"

	envLoader := goenvloader.NewBraceEnvironmentLoader()

	certFile, err := envLoader.LoadStringFromEnv(serverCrt)

	if err != nil {
		log.Fatal(err)
	}

	keyFile, err := envLoader.LoadStringFromEnv(serverKey)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Starting server at port 80\n")

	http.HandleFunc("/", authenticate.Authenticate)
	go redirectToHTTPS("443")

	if err := http.ListenAndServeTLS(":443", certFile, keyFile, nil); err != nil {
		log.Fatal(err)
	}

}

// func redirectTLS(w http.ResponseWriter, r *http.Request) {
// 	fmt.Println("https://" + hostName + ":8443" + r.RequestURI)
// 	http.Redirect(w, r, "https://"+hostName+":8443"+r.RequestURI, http.StatusMovedPermanently)
// }
func redirectToHTTPS(tlsPort string) {
	log.Println("Redirecting")
	httpSrv := http.Server{
		Addr: ":80",
		Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			host, _, _ := net.SplitHostPort(r.Host)
			u := r.URL
			u.Host = host
			u.Scheme = "https"
			log.Println(u.String())
			http.Redirect(w, r, u.String()+r.RequestURI, http.StatusMovedPermanently)
		}),
	}
	log.Println(httpSrv.ListenAndServe())
}
