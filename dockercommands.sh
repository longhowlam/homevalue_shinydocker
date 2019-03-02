docker build -t homevalue .

## list images
docker ps 
docker ps -a 
docker images


docker run -p 80:80 homevalue 
#docker run --rm -p 8786:8787 -e PASSWORD=ruser123 homevalue

# Delete dangling images
docker rmi $(docker images -f "dangling=true" -q)
docker rmi 4042c444acfd --force
## save
docker save -o ~/homevalueshinyapp.tar homevalue

## (re)load
docker load -i homevalueshinyapp.tar
docker run homevalue