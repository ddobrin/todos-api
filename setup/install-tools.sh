# Using Bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install todo-mysql-instance bitnami/mariadb --set rootUser.password=topsecret
helm install todo-redis-instance bitnami/redis --set global.redis.password=topsecret
