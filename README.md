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

Run a complete TPS instance with,

```
$ cd sawtooth-evote-node/docker/tps1
$ ./run.sh
```

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

## Vote process

```
$ cd sawtooth-evote-voter-machine
$ node index.js
```

You''ll be asked for k value (you get this value from activating process).

Example output,

```
node index.js
prompt: Cert path:  (../sawtooth-evote-ejbca/Dukcapil_DPT/52710501019120001_herpiko_dwi_aguno.pem) 
prompt: Key path:  (../sawtooth-evote-ejbca/Dukcapil_DPT/52710501019120001_herpiko_dwi_aguno.plain.key) 
prompt: k Value:  ccb0e8f04fb6a148NNiaXt5gi3upR12zkZsNWYqAgPNnwecewmNIr3qULk4=ueYsi8E/lSSCuW5S4+7EKaLNW+NP1cs0V+/3sQHA5oKzD4soaRRYX22mW5xYClejuToGdKDg+ZhrDuGSi2NkCQ==

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

prompt: 
Candidates : 
 - Prabowo - Hatta
 - Jokowi - Kalla
Please pick by number:  (2) 

Your k : ccb0e8f04fb6a148NNiaXt5gi3upR12zkZsNWYqAgPNnwecewmNIr3qULk4=ueYsi8E/lSSCuW5S4+7EKaLNW+NP1cs0V+/3sQHA5oKzD4soaRRYX22mW5xYClejuToGdKDg+ZhrDuGSi2NkCQ==

Your idv : cwAQwYsmIZwmmq27yU92Cae1y4KydemGNzrEDzqFtpg=ecewmNIr3qULk4=ueYsi8E/lSSCuW5S4+7EKaLNW+NP1cs0V+/3sQHA5oKzD4soaRRYX22mW5xYClejuToGdKDg+ZhrDuGSi2NkCQ==

Payload : {"cwAQwYsmIZwmmq27yU92Cae1y4KydemGNzrEDzqFtpg=ecewmNIr3qULk4=ueYsi8E/lSSCuW5S4+7EKaLNW+NP1cs0V+/3sQHA5oKzD4soaRRYX22mW5xYClejuToGdKDg+ZhrDuGSi2NkCQ==":"MIIHnwYJKoZIhvcNAQcCoIIHkDCCB4wCAQExDzANBglghkgBZQMEAgEFADCCAkMGCSqGSIb3DQEHAaCCAjQEggIwTUlJQm5nWUpLb1pJaHZjTkFRY0RvSUlCanpDQ0FZc0NBUUF4Z2dGRU1JSUJRQUlCQURBb01Cd3hHakFZQmdOVkJBTU1FVXRRVlVsdWRHVnliV1ZrYVdGMFpVTkJBZ2dSa2ZLR0RkSFZHREFOQmdrcWhraUc5dzBCQVFFRkFBU0NBUUJBSzB3OE1SdHZTVHNSbVU5TTk1OW44R1Y2S1BCaElWL3AvQm5WQldtNDZNLy91T0JRNm9VYUlka21VZnRMZC94SllFNnRTRVErNm8wWWxUSmp3d21uR2trRVBpbzVCRU54U2ZyRFlsRVUvUGF6VWE1aCtTaFB6RWsvT2tpeEZEUlM4ekw3Nyt3UEVHNjFXbTZ3VHlyc0tHSGdDbGpjRjhkamVTL2xwMXBBa2RIMXhQbmxUakE4MExSR25nbEdSVFhuZ1NwVFUwSUFMT01BeVJRYkNGbjRjSjFKZzBlRDJZejZaWm85RjFmejVRNE9HY0cvK2xRK3Q5a2Y3eGx3eDdrYzR5SWlwVTQ3TXpQc1pWMUxiZ1R6QXNzQ3htT2xIUURyZDlrUS9yWXFKT3dPQWxHVUNZUkM5TDE0SzI2b3NLeHFGUWVtRlBkM3RSWmlwbEI5SFUvM01ENEdDU3FHU0liM0RRRUhBVEFkQmdsZ2hrZ0JaUU1FQVNvRUVHME4rNVZlTTRJT2RJWldkbk1Dd3ZxZ0VnUVFnYWN1T3krZXE1cndURDNlOHlldWtnPT2gggNrMIIDZzCCAk+gAwIBAgIIBgO2nfvoOB8wDQYJKoZIhvcNAQELBQAwHDEaMBgGA1UEAwwRS1BVSW50ZXJtZWRpYXRlQ0EwHhcNMTgxMDE3MTAzNzQxWhcNMjAxMDE2MTAzNzQxWjAZMRcwFQYDVQQDDA50cHNfNTI3MTA1XzAwMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALf37SdIL0Eb/zEcuR0Q4JK3n4V/mXoGFEEvVeEXAl+rz7E56DCrKQfC0Rjg4TPG0ycOdnBB7KkoT2TC7IR8a/U6nc2VNQovqM0LqOmwN7Ltd4pKpAZdoapnizrp6q/i4zwpb0nb7oaDaoRe7wG4i7AtHQ0Bq363Hg6Vyu3UIEgCtgvrRPC7r1TXUNsvEThYYVTd3jbeVh5z0e0w+rrDLdwAbNKuW1sgG0StsyDMQwwrAPDjuZfwmteqeYUhUdsjoZXBVAgPpzyQT8k+2q56PkwJFlhvaDcBHL662C0EBoUTCcBDm7ivLN5yiCkW7WKMkaQT2IxmBcNGkf1k6KFtGGUCAwEAAaOBrzCBrDAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFCoAs13JJG/NWDBSbxTZ2mtxf+qyMEwGA1UdJQRFMEMGCyqBS7cYAQGWyH8BBgsqgUu3GAEBlsh/AgYIKwYBBQUHAwIGCCsGAQUFBwMEBgkqhkiG9y8BAQUGCCsGAQUFBwMBMB0GA1UdDgQWBBQPUuWZ/VH9/MZ2e+jvfs8jEwilijAOBgNVHQ8BAf8EBAMCBeAwDQYJKoZIhvcNAQELBQADggEBAG9rqcszy4xjhhy9Az8iAxrwZBGmQmj/PxjXTJDSUkoKN+lWW9DoHqSpJ4VlK5VDZOY46pyRyjvI8MdRbDRPV031iaLm/S3rDGC4EPyJnCKySARcwQ7NHvJBV3wT2XJAIZaHLgcIX5FP5mRJEQ0LE+ap01IKX+Ag60r+dCazPvbNDpNp+rAB5qokNR7Zgiuz8ZcoWSw8D+JXXkd6eT4E3qxMSuT5pDK56t1qS20mCgjuUf5p/qF3LF5jgg3b70o2lOUU2FUdREqv8Avm98tmJCwcq7DZo3nR/ko/Yjfhl4n673DM0XaLtDXuCORGINcA0IYJGXdXGhMmSt00eq87weIxggG+MIIBugIBATAoMBwxGjAYBgNVBAMMEUtQVUludGVybWVkaWF0ZUNBAggGA7ad++g4HzANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwLwYJKoZIhvcNAQkEMSIEILYdLZ7w6r5i+tCcNtUDqseVLX8DxLn1v/t2TrNYJtX7MBwGCSqGSIb3DQEJBTEPFw0xODEwMTgyMTA2MDhaMA0GCSqGSIb3DQEBAQUABIIBAJCHN1i4p4Ew/lvwnJUWWXBo9Lw0RDfiRzGSm34/Vr7GRgtrk3HTJwtqQ1uGx1Tjx3Xp5br02ooSGjNNAxYZC/qWlPx+c+mn6flyJHP45Tc2VlPLdLlr8y7WNITOMLQUnOm+c4nfjCLpdVCZAhysrHMOoYWTTcgK6QKGuW8ODJmfuidoJxiMJkzKJp3IuV8GojXbYvO2iiwMbq2KVwBNjQHOCNRE0FDsYZXuN5f0bDJOHPiRkcH3v0oXGeQxQ+zaUlgDuuIiYXMS27JwBlQRw0IVtlgdY2PIk19RRtuGMVMuDJaTw1AOMlZ6zkcXF/UhcMx98BtIR1Pw6IA9wnf0clw="}
{
  "data": [
    {
      "id": "0236ba00d13c0d82aa99b27dbe873ada758bd17d25673a0432c1310964ba5f5009519d6da38788f56dc930bc63561281601edf1687598108091e5f953410e400",
      "invalid_transactions": [],
      "status": "COMMITTED"
    }
  ],
  "link": "http://172.30.0.211:22311/batch_statuses?id=0236ba00d13c0d82aa99b27dbe873ada758bd17d25673a0432c1310964ba5f5009519d6da38788f56dc930bc63561281601edf1687598108091e5f953410e400"
}
```

You can check the bathes on local vote ledger.

## Counting and Recap

## Tallying

## Report