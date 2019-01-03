sync:
	rm -rf sawtooth-*
	git submodule update --init --recursive


national:
	docker network create --subnet=172.20.0.0/16 national
	-docker kill province-dpt-32.skripsi.local
	cd sawtooth-evote-node/docker/province-dpt-32 && ./run.sh
	-docker kill province-dpt-53.skripsi.local
	cd sawtooth-evote-node/docker/province-dpt-52 && ./run.sh

server:
	-docker kill $$(docker ps -a | grep evote-server | cut -d' ' -f1)
	cd sawtooth-evote-server && ./run.sh

tps1:
	-docker kill $$(docker ps -a | grep tps-1- | cut -d' ' -f1)
	-docker rm $$(docker ps -a | grep tps-1- | cut -d' ' -f1)
	-docker network rm tps1
	docker network create --subnet=172.30.0.0/16 tps1
	cd sawtooth-evote-node/docker/tps1 && ./run.sh
	cd sawtooth-evote-submitter && node tps-importer.js evote-server.skripsi.local:3443 172.30.0.111:21311

tps2:
	-docker kill $$(docker ps -a | grep tps-2- | cut -d' ' -f1)
	-docker rm $$(docker ps -a | grep tps-2- | cut -d' ' -f1)
	-docker network rm tps2
	docker network create --subnet=172.40.0.0/16 tps2
	cd sawtooth-evote-node/docker/tps2 && ./run.sh
	cd sawtooth-evote-submitter && node tps-importer.js evote-server.skripsi.local:3443 172.40.0.121:21321

phase1:
	make clean
	make national
	make server
	docker ps | grep skripsi.local

generate-dpt:
	(cd sawtooth-evote-submitter && npm run dpt-admin)
	(cd sawtooth-evote-client && npm run activate)  

generate-dpt-batch:
	(cd sawtooth-evote-submitter && npm run dpt-admin-batch)
	(cd sawtooth-evote-client && npm run activate-batch)  
	
phase2:
	docker kill $$(docker ps -a | grep skripsi.local | grep tps | cut -d' ' -f 1) || true
	docker rm $$(docker ps -a | grep skripsi.local | grep tps | cut -d' ' -f 1) || true
	make tps1
	make tps2
	docker ps | grep skripsi.local

phase3:
	-docker kill $$(docker ps -a | grep province-vote | cut -d' ' -f1)
	-docker rm $$(docker ps -a | grep province-vote | cut -d' ' -f1)
	cd sawtooth-evote-node/docker/province-vote-32 && ./run.sh
	cd sawtooth-evote-node/docker/province-vote-52 && ./run.sh

clean:
	-docker kill $$(docker ps -a | grep skripsi.local | cut -d' ' -f 1);
	-docker rm $$(docker ps -a | grep skripsi.local | cut -d' ' -f 1);
	-docker network rm national
	-docker network rm tps1
	-docker network rm tps2
