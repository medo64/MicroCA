### Micro CA ###

Wrapper around openssl for creation of self-signed CA and certificates.

  
#### SYNOPSIS####

	microca.sh [-a] [-b <numbits>] [-c <fileprefix>] [-d <days>] [-e] [-r] [-u <usagebits>] [-v] [-x] file

`-a`  
Marks certificate as certificate authority.

`-b <numbits>`  
Number of bits to use for key. Default value is 2048.

`-c <ca>`  
Prefix for CA (default value is ca).

`-d <days>`  
Number of days certificate is valid for. Default value is 3650 days.

`-e`  
Exports the resulting key as PKCS12 file.

`-r`  
Creates a self-signed root certificate authority.

`-u <usagebits>`  
Certificate usage bits. It must be one of following usages: digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign, cRLSign, encipherOnly, decipherOnly, serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, msCodeInd, msCodeCom, msCTLSign, msSGC, msEFS, or nsSGC. Additionally one can specify CA (cRLSign and keyCertSign), Server (digitalSignature, keyEncipherment, and serverAuth), or Client (clientAuth). If multiple usages are required, you can separate them with comma (,).

`-x`  
Do not use passphrase for private key.

`-v`  
Verbose output.

`file`  
File name prefix to use for key and certificate.


#### SAMPLES ####
  
	./microca.sh -r
	./microca.sh -r -b 4096 -d 30
	./microca.sh -u Server server
	./microca.sh -u Client client
