# Sawtooth Evote

## Introduction

- `client` - Client app that will be used by DPT
- `ejbca` - Contains all necessary keys and certificates
- `node` - The nodes of blockchain, dockerized
- `server` - The main server that handle DPT activation and tallying
- `submitter` - A client of the blockchain node. It could commit transaction to a node
- `transaction-processor` - Blockchain's transaction processors

## Spinning up

### Clone the repositories

```
$ git clone git@github.com:herpiko/sawtooth-evote-client.git
$ git clone git@github.com:herpiko/sawtooth-evote-ejbca.git
$ git clone git@github.com:herpiko/sawtooth-evote-node.git
$ git clone git@github.com:herpiko/sawtooth-evote-server.git
$ git clone git@github.com:herpiko/sawtooth-evote-submitter.git
$ git clone git@github.com:herpiko/sawtooth-evote-transaction-processor.git
```

If there is a package.json file inside them, simply run yarn to install the dependencies,

```
$ cd sawtooth-evote-client
$ yarn
```

### Blockchain Node

#### Docker Network

Few separated docker network will be used, `national` and `tps`
```
$ docker network create --subnet=172.20.0.0/16 national
$ docker network create --subnet=172.30.0.0/16 tps1
$ docker network create --subnet=172.30.0.0/16 tps2
```

#### DPT Node

There are two DPT node named `province-dpt-32` and `province-dpt-52` under `sawtooth-evote-node/docker`. Just run them using their `run.sh` script. Note that `province-dpt-32` is mandatory to run first since the it contains the genesis block. Run them in separated terminal session.

```
$ cd docker/province-dpt-32
$ ./run.sh
```

```
$ cd docker/province-dpt-52
$ ./run.sh
```

#### Vote Node

To be written.

#### TPS Node

To be written

### Server

This instance serves API request from `client` app and others. Simply execute the script to run it.

```
$ cd sawtooth-evote-server
$ ./run.sh
```

You may check the instance on `http://localhost:3000` in your browser.


## DPT Preparation

### Registering a DPT

As KPU, we want to register a citizen.

```
$ cd sawtooth-evote-submitter
$ node dpt-admin.js
```

You'll be asked for a voterId (Common Name of the DPT's certificate), state of the DPT and the DPT ledger address. They are autofilled for demo purpose.

Example output :

```
$ node dpt-admin.js 
prompt: voterId:  (52710501019120001_Herpiko_Dwi_Aguno) 
prompt: verb [registered, invalid, ready]:  (registered) 
prompt: node host:port:  (localhost:11332) 
Name : 795cc6c85f2182e7999909c622f674b5a2311beed3945442526a687e64d745f8
Family name : provinceDPT
Payload name : 795cc6c85f2182e7999909c622f674b5a2311beed3945442526a687e64d745f8
StateID : 41bd53281d6d9ed423e1c066e26029136e36f459cf3b8c321f9de020243bd0ab9eddb5
{ id: '17e7be071689500b9837c1f9a8ecf938567fa3aa7f6fb863ce5afeef28a79c636a48ff3af5cce4a2b53ab43efa7bb039898b846fc5d8ea2573a3724159d91400',
  invalid_transactions: [],
  status: 'COMMITTED' }
```

We can check the transaction on `http://localhost:3000/api/dpt-transactions`

Example output :

```
{
	"data": [{
		"header": {
			"batcher_public_key": "03fd230edc50af7650176589d...",
			"dependencies": [],
			"family_name": "provinceDPT",
			"family_version": "1.0",
			"inputs": ["41bd53281d6d9ed423e1c066..."],
			"nonce": "",
			"outputs": ["41bd53281d6d9ed423e1c066e260..."],
			"payload_sha512": "7d0dcb12e8e93eb4b054f2adae52...",
			"signer_public_key": "03fd230edc50af7650176589d..."
		},
		"header_signature": "ced5f77175411237e5fa548b4c...",
		"payload": "o2RWZXJianJlZ2lzdGVyZW..."
	}, {
	...
	
```

The `dpt-admin.js` can be used to manipulate the DPT state.

### Activating as DPT

Assume that now you are the DPT (`52710501019120001_Herpiko_Dwi_Aguno`) and want to activate your account so you'll be a legal voter for the election. You can use the client app to activate. It also has been autofilled for demo purpose. The first argument is action type.

```
$ cd sawtooth-evote-client
$ node index.js localhost:3000
node index.js activate
prompt: Cert path:  (../sawtooth-evote-ejbca/Dukcapil_DPT/52710501019120001_herpiko_dwi_aguno.pem) 
prompt: Key path:  (../sawtooth-evote-ejbca/Dukcapil_DPT/52710501019120001_herpiko_dwi_aguno.plain.key) 

VOTER IDENTITY on ../sawtooth-evote-ejbca/Dukcapil_DPT/52710501019120001_herpiko_dwi_aguno.pem
=====================================
2.5.4.13 : 52710501019120001_herpiko_dwi_aguno
commonName : 52710501019120001_herpiko_dwi_aguno
2.5.4.42 : Herpiko
2.5.4.4 : Dwi Aguno
localityName : 71.05
stateOrProvinceName : 52
countryName : ID
=====================================

Verifying cert against CA...
- Verified
Verifying cert against CRL...
- Verified

52710501019120001_herpiko_dwi_aguno
nameHash : 37eb1d2a77f920ce...
payloadNameHash : b64c1351115db0670330b2818d...
stateId : 41bd53cb8dda2641ceb25850989c18aec4360e11de123fc480278f4fd249220d4718cd
action : activate
activating
{"signedKey":"QbM2jM...","status":"READY"}
This KDF is stored in smartcard and smartphone : 
dd999b1d2689f123QbM2jMUh0KvYFqEqjNR3XNoZnAQHGJ0AtBhaCAh916w=VTf3jAYC467wRCmQ2ndrAM4YewP7LvaqVyxVNybspX/wMb+c1iE0AhRJqHlqu05GTZB6CYwlaV4jeME5VZPKAQ==
Your idv value : 
0MWlETXu1/T+hknlVoGTmVzARAtMnLvlVgh+U3Pq9RU=J0AtBhaCAh916w=VTf3jAYC467wRCmQ2ndrAM4YewP7LvaqVyxVNybspX/wMb+c1iE0AhRJqHlqu05GTZB6CYwlaV4jeME5VZPKAQ==
```

A QR code image will also be appear. It contains the KDF key. The client also could be used to obtains the idv value from KDF key (offline) and checking the state of the DPT (online).

