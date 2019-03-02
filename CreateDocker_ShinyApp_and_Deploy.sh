## Script to bluid docker image en push it to your kubernetes cluster on GCP
## Then start the services.....


## set project id
export PROJECT_ID="$(gcloud config get-value project -q)"

## build
docker build -t gcr.io/${PROJECT_ID}/shinyhome-app:v1 .

docker images

### run the shiny app locally
docker run --rm -p 80:80 gcr.io/${PROJECT_ID}/shinyhome-app:v1

## push image to gcp
docker push gcr.io/${PROJECT_ID}/shinyhome-app:v1

## deploy image, takes some time (~ 1 min) to finish
kubectl run shinyhome-web --image=gcr.io/${PROJECT_ID}/shinyhome-app:v1 --port 80

## To see the Pod created by the Deployment, run the following command:

kubectl get pods
# expose them now to the internet
kubectl expose deployment shinyhome-web --type=LoadBalancer --port 80 --target-port 80

kubectl get service

### now you can go to the external ip address and see the shiny app



