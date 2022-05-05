docker-build:
	docker build -t martinsimango/kube-authorization-webhook .

docker-push:
	docker push  martinsimango/kube-authorization-webhook:latest

docker-run:
	docker run --rm --name kube-authorization-webhook \
		-p 8080:80 \
		-p 8443:443 \
		martinsimango/kube-authorization-webhook \


kube-apply:
	kubectl create -f k8s/webhook.yaml
	kubectl create -f k8s/webhook-service.yaml
	docker exec kind-cluster-control-plane /bin/bash -c update-ca-certificates 
	sleep 5
	sudo kubectl port-forward svc/kube-authorization-webhook-svc 443             

