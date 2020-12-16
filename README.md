# Introduction
TODOS-API is a sample Spring Boot Microservice that uses spring-boot-starter-web to implement a REST API for TODO(s).

The service fits into a larger TODO application, which includes a WebUI, an edge service, as well as caching and database services.

![alt text](https://github.com/tanzu-platform-architecture-canada/todos-api/blob/master/images/rest-api.png "TODO Application")

The service can be accessed from a Web UI or directly at the endpoints it exposes.

## The Domain Model
The Domain Model is a TODO object which has an id, a title, a category, the deadline and the status.
```json
ex.:
{
    "category": "personal",
    "complete": false,
    "deadline": "2020/10/01",
    "id": "4d0918be-36fa-4dcd-b7b8-14200ef31d4c",
    "title": "todo3"
}
```
## Endpoints

`todos-api` exposes multiple endpoints, by default running at port `8082`:

* `/` - [GET] returns all TODO items 
* `/{id}` - [GET] returns a TODO items for the specified id
* `/` - [POST] creates a new TODO item
* `/{id}` - [POST] creates a new TODO item with a specified id, in lieu of an auto-generated id
* `/{id}` - [PATCH] updates an existing TODO item 
* `/` - [DELETE] - deletes all TODOs in the database and evicts the cache
* `/{id}` - [DELETE] - deletes a TODO for the specified id

`todos-api` exposes additionally a separate set of endpoints for introspection, out-of-the-box and customized

* `/actuator` - [GET] returns all actuators enabled in the application; by default almost all available actuators have been enabled, for educational purposes
* `/actuator/health` - [GET] returns the OOB health info + customized health info collected from the service
* `/actuator/custom` - [GET] implements a custom actuator
* `/actuator/info` - [GET] collects customized info from the application

## Pre-requisites for using TODOS-API
Building and running the application assumes that you have installed a number of pre-requisites:

* Java 8 - configured to run the application by default. You can decided to build and run the app also with Java 11 or 14 
* Maven - compiling the application and running tests
* Helm v3 - for installing the caching and database solutions. [Helm installation link](https://helm.sh/docs/intro/install/).
* Skaffold - for building, pushing, deploying and debugging the application. [Skaffold installation link](https://skaffold.dev/docs/install/).
* Kustomize - for using a template-free way to customize application configuration that simplifies the use of off-the-shelf applications. [Kustomize installation link](https://kubernetes-sigs.github.io/kustomize/installation/).
* HTTPie - highly recommended as a cUrl replacement for a user-friendly command-line HTTP client for the API era. It comes with JSON support, syntax highlighting, persistent sessions, wget-like downloads, plugins, etc. [HTTPie installation link](https://httpie.org/).
* Kubectl - the Kubernetes CLI, allows you to run commands against Kubernetes clusters. [Kubectl installation link](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Setup pre-requisite services

This repo contains 4 scripts for setting up, respectively cleaning up pre-requisite tolls and Spring Boot microservices for usage with the TODOS-API application.

```shell
# Setup - please run in order
./setup/install-tools.sh -- Helm chart based installer for caching and database
cd setup
./setup-app.sh -- kubectl-based deployment for 4 services for the TODO app

# installation can be validated by checking all running services in K8s
kubectl get services

# Ex.:
NAME                                TYPE           CLUSTER-IP    EXTERNAL-IP       PORT(S)          AGE
kubernetes                          ClusterIP      10.0.0.1      <none>            443/TCP          93d
todo-mysql-instance-mariadb         ClusterIP      10.0.12.243   <none>            3306/TCP         3d22h
todo-mysql-instance-mariadb-slave   ClusterIP      10.0.1.47     <none>            3306/TCP         3d22h
todo-redis-instance-headless        ClusterIP      None          <none>            6379/TCP         3d22h
todo-redis-instance-master          ClusterIP      10.0.0.20     <none>            6379/TCP         3d22h
todo-redis-instance-slave           ClusterIP      10.0.3.76     <none>            6379/TCP         3d22h
todos-mysql                         LoadBalancer   10.0.1.43     35.223.204.37     9090:30207/TCP   47h
todos-redis                         LoadBalancer   10.0.14.98    104.154.253.234   8888:31530/TCP   47h
todos-service                       LoadBalancer   10.0.11.54    35.225.226.171    9999:30011/TCP   47h
todos-webui                         LoadBalancer   10.0.14.60    104.197.8.27      8080:30908/TCP   47h

# Cleanup - please run in order
./setup/cleanup-tools.sh -- Helm chart based installer for caching and database
./setup/remove-app.sh -- kubectl-based removal for 4 services for the TODO app
```

## Compiling and Building and Image for the TODOS-API
The application is configured by default with Java 8 in the Maven pom.xml file. You can update it to Java 11 or Java 14 if you choose to do so.

__Local development__

The app can be built and started locally from the command-line or from withing an IDE
```shell
./mvnw clean package
```

__Images__

To build and run Docker images, start clean by checking that no todos-api images exist on your machine by executing
```shell
docker images | grep todos-api | awk '{print $3}' | xargs docker rmi -f
```

To compile the code and build an image for ```todos-api```, this repo illustrates 3 methods. 

A pre-built image has already been provisioned in Docker Hub at this [todos-api link](https://hub.docker.com/repository/docker/triathlonguy/todos-api) and can be retrieved by executing ```docker pull triathlonguy/todos-api:latest```

__1. Spring Boot image builder - as of Spring 2.3.x, uses Paketo buildpacks__
```shell
mvn clean spring-boot:build-image

# validate image creation
docker images | grep todos-api
```

__2. Skaffold__
```shell
# builds the image only
skaffold build

# validate image creation
docker images | grep todos-api
```

## Running TODOS-API in a local environment
The app can be built and started locally from the command-line or from withing an IDE
```shell
./mvnw clean package
java -jar target/todos-api-1.2.0-SNAPSHOT.jar 

# requests can be sent to localhost:8082
# /src/main/resources/application.yaml needs to be updated with the endpoints of the cache, respectively database
```

## Deploying TODOS-API in Kubernetes using kubectl
The app can be deployed and started in any Kubernetes environment using kubectl 
```shell
kubectl apply -f kubernetes/app
```

Removing the ```todos-api``` deployment can be done by executing
```shell
kubectl delete -f kubernetes/app
```

## Deploying, Developing & Debugging in Kubernetes with Skaffold
Skaffold is a command line tool that facilitates continuous development for Kubernetes applications. It simplifies the development process by combining multiple steps into one easy command and provides the building blocks for a CI/CD process.

Developers can use Skaffold to manage the development lifecycle of the todos-api by executing
```shell
skaffold dev 
```

Skaffold builds the application, deploys it and monitors for any changes. If any file is changed, from an IDE or text editor, Skaffold will trigger a fresh build and deploy process.

To end the working session, just press CTRL-C in the terminal window from where the Skaffold command has been executed. Skaffold will clean up all deployed artifacts.

Skaffold allows developers to have remote debugging sessions in Kubernetes, by executing
```shell
skaffold debug --port-forward -f skaffold.yaml 
```

Skaffold will forward port 5005, where a remote debugging session can be setup in IntelliJ/Eclipse/VSCode. 

Please set up a remote session in your favorite IDE at port 5005, set up breakpoints and send HTTP requests to the API at the configured for this app (8080 is the default).

IDEs indicate when the remote connection has been established:
```code
Connected to the target VM, address: 'localhost:5005', transport: 'socket'
```


## Deploying, Developing & Debugging in Kubernetes with Externalized Configurations using Skaffold & Kustomize
* One of the [12 factors for cloud native apps is to externalize configuration](https://12factor.net/config)
* Kubernetes provides support for externalizing configuration via config maps and secrets
* A config map or secret can easily be created using kubectl
* Kustomize offers a much improved way of generating config maps and secrets as part of our customizations to different environments, which can be versioned and managed in Source Control

Kustomize features
* Allows easier deployments to different environments/providers
* Allows you to keep all the common properties in one place
* Generate configuration for specific environments
* No templates, no placeholder spaghetti, no environment variable overload

For example, if we wish to deploy the app to a QA environment, we wish to customize some of the configuration. 

This repo has an example of a QA environment which scales the todos-api to 2 replicas, as per the ```update-replicas.yaml``` customization file made available in ```/kubernetes/overlays/qa```

Deploy the ```todos-api``` using Skaffolf + Kustomize for the imaginary QA environment by executing
```shell
skaffold dev -p qa

# note that the skaffold.yaml file is not specified, as Skaffold looks by default for a file called skaffold.yaml, which is availalble in this repo

# observe that 2 replicas of the todos-api have been created
pod/todos-api-7f795466ff-7gp5w             1/1     Running   0          9s
pod/todos-api-7f795466ff-k9jkx             1/1     Running   0          10s
```

## Usage Examples for Application & Actuator endpoints
Once the app is deployed in Kubernetes, please retrieve the endpoint at which ```todos-api``` is exposed
```shell
kubectl get svc

# example
NAME      TYPE           CLUSTER-IP    EXTERNAL-IP       PORT(S)          AGE
todos-api LoadBalancer   10.0.13.177   35.193.98.123     8082:31783/TCP   15m
```
To ```add a new TODO item```, say ```todo0``` execute:
```shell
http <external_svc_ip>:8082 completed=false title=todo0 category=personal deadline=2020/10/01

http 35.193.98.123:8082 completed=false title=todo0 category=personal deadline=2020/10/01

{
    "category": "personal",
    "complete": false,
    "deadline": "2020/10/01",
    "id": "0d892025-8425-4af4-bf72-979a02b3d4bc",
    "title": "todo0"
}
```

To ```retrieve all TODO items``` execute:
```shell
http <external_svc_ip>:8082

http 35.193.98.123:8082
# or 
curl 35.193.98.123:8082

[
    {
        "category": "personal",
        "complete": false,
        "deadline": "2020/10/01",
        "id": "0d892025-8425-4af4-bf72-979a02b3d4bc",
        "title": "todo0"
    },
    {
        "category": "Default group",
        "complete": false,
        "deadline": "2020/09/14",
        "id": "cc56f488-57df-447d-a161-e59ed21bb230",
        "title": "todo1"
    }
]
```

To ```retrieve a TODO item by {id}``` execute:
```shell
http <external_svc_ip>:8082/{id}

http 35.193.98.123:8082/0d892025-8425-4af4-bf72-979a02b3d4bc
# or 
curl 35.193.98.123:8082/0d892025-8425-4af4-bf72-979a02b3d4bc

{
    "category": "personal",
    "complete": false,
    "deadline": "2020/10/01",
    "id": "0d892025-8425-4af4-bf72-979a02b3d4bc",
    "title": "todo0"
}
```

To retrieve the ```customized Info Actuator``` data execute
```shell
http <external_svc_ip>:8082/actuator/info

http 35.193.98.123:8082/actuator/info
# or
curl 35.193.98.123:8082/actuator/info

{
    "app": {
        "description": "TODOs - API - business logic w/ DB and cache access",
        "name": "todos-api - Spring Boot Application"
    }
}
```

To retrieve the ```customized Health Actuator``` data execute
```shell
http <external_svc_ip>:8082/actuator/health

http 35.193.98.123:8082/actuator/health
# or
curl 35.193.98.123:8082/actuator/health

{
    "components": {
        "customHealthCheck": {
            "details": {
                "Custom Health Check Status": "passed"
            },
            "status": "UP"
        },
        "diskSpace": {
            "details": {
                "exists": true,
                "free": 80728559616,
                "threshold": 10485760,
                "total": 101241290752
            },
            "status": "UP"
        },
        "livenessState": {
            "status": "UP"
        },
        "ping": {
            "status": "UP"
        },
        "readinessState": {
            "status": "UP"
        }
    },
    "groups": [
        "liveness",
        "readiness"
    ],
    "status": "UP"
}
```

To access a ```Custom Actuator``` introduced for educational purposes execute
```shell
http <external_svc_ip>:8082/actuator/custom

http 35.193.98.123:8082/actuator/custom
# or
curl 35.193.98.123:8082/actuator/custom

{
    "CustomEndpoint": "Everything looks good at the custom endpoint"
}
```
