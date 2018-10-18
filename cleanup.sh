docker kill $(docker ps -a | grep skripsi.local | cut -d' ' -f 1);
docker rm $(docker ps -a | grep skripsi.local | cut -d' ' -f 1);
