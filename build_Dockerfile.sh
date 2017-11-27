# To build this image, source the file

# Build user setup
docker build -t $USER/jupplot -f Dockerfile .
alias dp='docker run -ti --rm -p 8888:8888 -e DISPLAY=$(ifconfig|grep "inet "|grep -v 127.0.0.1|cut -d" " -f2):0 -v /tmp/.X11-unix:/tmp/.X11-unix -v "$PWD":/home/jovyan/work --name jupplot $USER/jupplot'
alias dpe='docker exec -it jupplot'