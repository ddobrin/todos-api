# Using Bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami
#helm install todo-mysql-instance bitnami/mariadb --set rootUser.password=topsecret
# install mysql
helm install todo-mysql-instance-1  --set auth.rootPassword=topsecret bitnami/mariadb

#install redis
helm install todo-redis-instance bitnami/redis --set global.redis.password=topsecret


