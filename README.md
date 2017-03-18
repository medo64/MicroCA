### Micro CA ###

Wrapper around openssl for creation of self-signed CA and certificates.

  
#### SYNOPSIS ####

    microca.sh [-a] [-b <numbits>] [-c <fileprefix>] [-d <days>] [-e]
               [-i <ipaddress>] [-m <email>] [-n <dnsname>] [-p] [-r]
               [-s <subject>] [-u <usagebits>] [-v] [-x] fileprefix

`-a`  
Marks certificate as certificate authority.

`-b <numbits>`  
Number of bits to use for key. Default value is 2048.

`-c <fileprefix>`  
Prefix for CA (default value is ca).

`-d <days>`  
Number of days certificate is valid for. Default value is 3650 days.

`-e`  
Exports the resulting key as PKCS12 file.


`-i <ipaddress>`  
IP address to add into subjectAltName extension. Can be repeated multiple times.

`-m <email>`  
E-mail address to add into subjectAltName extension. Can be repeated multiple times.

`-n <dnsname>`  
DNS name to add into subjectAltName extension. Can be repeated multiple times.

`-p`  
Creates a self-signed end entity certificate, i.e. no certificate authority is used.

`-r`  
Creates a self-signed root certificate authority.

`-s <subject>`  
Full subject for a certificate (e.g. -s /C=US/CN=www.example.com).

`-u <usagebits>`  
Certificate usage bits. It must be one of following usages: digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign, cRLSign, encipherOnly, decipherOnly, serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, msCodeInd, msCodeCom, msCTLSign, msSGC, msEFS, or nsSGC. Additionally one can specify CA (cRLSign and keyCertSign), Server (digitalSignature, keyEncipherment, and serverAuth), Client (clientAuth), or BitLocker (1.3.6.1.4.1.311.67.1.1). If multiple usages are required, you can separate them with comma (,).

`-v`  
Verbose output. It can be used multiple times for greater amount of details.

`-x`  
Do not use passphrase for private key.

`fileprefix`  
File name prefix to use for key and certificate.


#### SAMPLES ####

##### Root CA #####

    ./microca.sh -r

CreateS a root certificate authority. User is asked password for the key and all details of the certificate (e.g. subject). Key is placed into ca.key and certificate is into ca.cer.

    ./microca.sh -r -b 4096

Same as the first command but key length is specified to be 4096 bits (default is 2048).

    ./microca.sh -r -b 4096 -s "CN=My Root CA"

Instead of being asked for subject, subject is defined on the command line.

    ./microca.sh -r -b 4096 -s "CN=My Root CA" -d 365

The created root certificate is valid for 1 year only (default is 10 years).


##### Intermediate CA #####

    ./microca.sh -a -b 2048 -s "CN=My Intermediate CA" inter-ca

Creates an intermediate CA with 2048 bit long key and subject text specified on command line. Key is placed into inter-ca.key and certificate is into inter-ca.cer.


##### End entity #####

    ./microca.sh test

Creates an end-entity certificate signed using ca.key and ca.cer. User will be asked password for newly created key (and CA key, if password is present) and all the details of the certificate (e.g. subject). Key is placed into test.key and certificate is into test.cer.

    ./microca.sh -x test

Same as above but without a password for newly created key.

    ./microca.sh -ex test

Same as above but certificate and key are additionally exported to test.p12 PKCS#12 container.

    ./microca.sh -exu Server server

Same as above but certificate is created with usage bits for server (digitalSignature, keyEncipherment, and serverAuth).

    ./microca.sh -exu Server -n localhost -i 127.0.0.1 -s "CN=localhost" server

Same as before but certificate also contains subjectAltName with localhost as DNS name and 127.0.0.1 as IP address. Subject is also defined to be CN=localhost.

    ./microca.sh -exu Client client

Same as before but certificate is created with usage bits for client (clientAuth).

    ./microca.sh -exu BitLocker bitlocker

Same as before but certificate is created with usage bits for bitlocker (keyEncipherment and 1.3.6.1.4.1.311.67.1.1).

    ./microca.sh -exu BitLocker -c inter-ca bitlocker

Same as before but certificate is signed by intermediate CA (contained into inter-ca.key and inter-ca.cer).

    ./microca.sh -xpb 1024 -s "CN=My Test" test

Creates an self-signed end-entity certificate with 1024 bit RSA key and with subject CN=My Test. Key is placed into test.key and certificate into test.cer.
