### Micro CA ###

Wrapper around openssl for creation of self-signed CA and certificates.

  
#### SYNOPSIS ####

    microca.sh [-a] [-b <numbits>] [-c <fileprefix>] [-d <days>] [-e] [-p] [-r] [-s <subject>] [-u <usagebits>] [-v] [-x] file

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

`-p`  
Creates a self-signed end entity certificate, i.e. no certificate authority is used.

`-r`  
Creates a self-signed root certificate authority.

`-s <subject>`  
Full subject for a certificate (e.g. -s /C=US/CN=www.example.com).

`-u <usagebits>`  
Certificate usage bits. It must be one of following usages: digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign, cRLSign, encipherOnly, decipherOnly, serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, msCodeInd, msCodeCom, msCTLSign, msSGC, msEFS, or nsSGC. Additionally one can specify CA (cRLSign and keyCertSign), Server (digitalSignature, keyEncipherment, and serverAuth), Client (clientAuth), or BitLocker (1.3.6.1.4.1.311.67.1.1). If multiple usages are required, you can separate them with comma (,).

`-x`  
Do not use passphrase for private key.

`-v`  
Verbose output. It can be used multiple times for greater amount of details.

`file`  
File name prefix to use for key and certificate.


#### SAMPLES ####
  
    ./microca.sh -r
    ./microca.sh -r -b 4096
    ./microca.sh -r -b 4096 -s "CN=My Root CA"
    ./microca.sh -a -b 2048 -s "CN=My Intermediate CA"
    ./microca.sh -p -b 1024 -s "CN=My Test" test
    ./microca.sh -u Server server
    ./microca.sh -u Client client
    ./microca.sh -u BitLocker -e bitlocker
