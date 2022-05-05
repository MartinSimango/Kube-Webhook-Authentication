FROM golang:1.18-alpine
RUN apk update && apk add --no-cache git
RUN apk add build-base


ENV GOPATH /go
ENV GOBIN /go/bin
ENV CGO_ENABLED 0
RUN mkdir -p /go/bin

WORKDIR /app

COPY go.mod .
COPY go.sum . 
RUN go mod download
RUN go mod verify

COPY . .
RUN go build -o kube-authorization-webhook
RUN mv kube-authorization-webhook /go/bin


FROM scratch 

EXPOSE 80
EXPOSE 443


ENV SERVER_CERT /etc/ssl/certs/server.crt
ENV SERVER_KEY /etc/ssl/certs/server.key

WORKDIR /app
COPY --from=0 /go/bin/kube-authorization-webhook kube-authorization-webhook
COPY --from=0 /app/certs/server.crt /etc/ssl/certs/server.crt
COPY --from=0 /app/certs/server.key /etc/ssl/certs/server.key


ENTRYPOINT ["/app/kube-authorization-webhook"]

EXPOSE 80

EXPOSE 443