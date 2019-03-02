# homevalue_shinydocker
Some files to create home value prediction shiny app, package that in a docker, create a kubernetes cluster on GCP and deploy the image.

The folder homevalue_prediction contains the R shiny app

The Dockerfile contains the instructions for the docker container

CreateKubernetesCluster.sh contains the gcloud command to spin up a kubernetes cluster

CreateDocker_ShineApp_and_Depluy.sh contains the commands to build the image and deploy it to GCP kubernetes clusetr and expose the service