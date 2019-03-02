docker build -t homevalue .

## list images
docker ps 
docker ps -a 
docker images


docker run -p 80:80 homevalue 
#docker run --rm -p 8786:8787 -e PASSWORD=ruser123 homevalue

# Delete dangling images
docker rmi $(docker images -f "dangling=true" -q)
docker rmi 6703370c4fc2 --force
## save
docker save -o ~/homevalue.tar homevalue

## (re)load
docker load -i homevalue.tar
docker run homevalue