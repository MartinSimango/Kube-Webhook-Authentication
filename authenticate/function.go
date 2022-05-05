package authenticate

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strings"

	authentication "k8s.io/api/authentication/v1beta1"
)

type User struct {
	username string
	password string
	group    string
}

var users = []User{
	{
		username: "martin",
		password: "password",
		group:    "system:masters",
	},
}

func Authenticate(w http.ResponseWriter, r *http.Request) {
	fmt.Println("At start of authentication")
	decoder := json.NewDecoder(r.Body)

	var tr authentication.TokenReview
	err := decoder.Decode(&tr)
	if err != nil {
		fmt.Println("ERROR occured: ", r.Body)
		handleError(w, err)
		return
	}

	user, err := logon(tr.Spec.Token)
	if err != nil {
		handleError(w, err)
		return
	}

	log.Printf("[Success] login as %s\n", user.username)

	w.WriteHeader(http.StatusOK)
	trs := authentication.TokenReviewStatus{
		Authenticated: true,
		User: authentication.UserInfo{
			Username: user.username,
			Groups:   []string{user.group},
		},
	}
	tr.Status = trs

	json.NewEncoder(w).Encode(tr)

}

func handleError(w http.ResponseWriter, err error) {
	log.Println("[Error] ", err.Error())

	tr := new(authentication.TokenReview)
	trs := authentication.TokenReviewStatus{
		Authenticated: false,
		Error:         err.Error(),
	}

	tr.Status = trs
	w.WriteHeader(http.StatusUnauthorized)
	json.NewEncoder(w).Encode(tr)

}

func logon(token string) (*User, error) {
	data := strings.Split(token, ";")
	if len(data) < 3 {
		return nil, errors.New("no token data")
	}
	for _, u := range users {
		if u.group == data[0] && u.username == data[1] && data[2] == u.password {
			return &u, nil
		}
	}

	return nil, errors.New("user" + data[1] + "not found")
}
