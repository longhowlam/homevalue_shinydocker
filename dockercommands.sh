docker build -t homevalue .

## list images
docker ps 
docker ps -a 
docker images

docker stop 1eb9365d350e
docker run -p 80:80 homevalue 
#docker run --rm -p 8786:8787 -e PASSWORD=ruser123 homevalue

# Delete dangling images
docker rmi $(docker images -f "dangling=true" -q)
docker rmi e43d2230f5ff --force
## save
docker save -o ~/Documents/DockerProjecten/homevalue_shinydocker/homevalueshinyapp.tar homevalue
docker save -o homevalueshinyapp.tar homevalue
## (re)load
docker load -i homevalueshinyapp.tar
docker run -p 80:80 homevalue