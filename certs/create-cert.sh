#!/bin/bash

rm *.key
rm *.crt
rm *.csr
rm *.srl

# #CA
openssl genrsa -out ca.key 2048  

openssl req -key ca.key -new -out ca.csr -subj \
"/CN=Authorization-Webhook-CA" -sha256 

openssl x509  -req -in ca.csr -signkey ca.key -out ca.crt -sha256


# create keys
openssl genrsa -out server.key 2048

# create csr
openssl req -key server.key -new -out server.csr -subj \
"/CN=authorization.webhook.cluster.local" -sha256 -config san.cnf

# sign csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -out  server.crt -CAcreateserial -sha256 -extfile san.cnf -extensions req_ext 


# view cert

# openssl x509 -in ca.crt -text -noout

# openssl req -in ca.csr -text -noout