# deploy microservices
kubectl apply -f app/mysql-app.yml
kubectl apply -f app/redis-app.yml
kubectl apply -f app/webui-app.yml
kubectl apply -f app/edge-app.yml