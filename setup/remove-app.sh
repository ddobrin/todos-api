# remove deployed microservices
kubectl delete -f app/mysql-app.yml
kubectl delete -f app/redis-app.yml
kubectl delete -f app/webui-app.yml
kubectl delete -f app/edge-app.yml
