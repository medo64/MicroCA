#!/bin/bash
COMMAND_LINE="$0 $*"

KEY_SIZE="2048"
KEY_PASSPHRASE_CIPHER="aes256"

CA_PREFIX="ca"
CA_CREATE=0
CA_CREATE_ROOT=0

CERTIFICATE_DAYS=3650
CERTIFICATE_USAGES=""
CERTIFICATE_EXTENDED_USAGES=""
CERTIFICATE_SUBJECT=""
CERTIFICATE_SELF=0

EXPORT=0
VERBOSE=0
OUTPUT_PREFIXES=""

while getopts ":ab:c:d:ehprs:u:vx" OPT; do
    case $OPT in
        h)
            echo
            echo    "  SYNOPSIS"
            echo -e "  `echo $0 | xargs basename` [\033[4m-a\033[0m] [\033[4m-b <numbits>\033[0m] [\033[4m-c <fileprefix>\033[0m] [\033[4m-d <days>\033[0m] [\033[4m-e\033[0m] [\033[4m-p\033[0m] [\033[4m-r\033[0m] [\033[4m-s <subject>\033[0m] [\033[4m-u <usagebits>\033[0m] [\033[4m-v\033[0m] [\033[4m-x\033[0m] \033[4mfile\033[0m" | fmt
            echo
            echo -e "    \033[4m-a\033[0m"
            echo    "    Marks certificate as certificate authority." | fmt
            echo
            echo -e "    \033[4m-b <numbits>\033[0m"
            echo    "    Number of bits to use for key. Default value is 2048." | fmt
            echo
            echo -e "    \033[4m-c <ca>\033[0m"
            echo    "    Prefix for CA (default value is ca)." | fmt
            echo
            echo -e "    \033[4m-d <days>\033[0m"
            echo    "    Number of days certificate is valid for. Default value is 3650 days." | fmt
            echo
            echo -e "    \033[4m-e\033[0m"
            echo    "    Exports the resulting key as PKCS12 file." | fmt
            echo
            echo -e "    \033[4m-p\033[0m"
            echo    "    Creates a self-signed end entity certificate, i.e. no certificate authority is used." | fmt
            echo
            echo -e "    \033[4m-r\033[0m"
            echo    "    Creates a self-signed root certificate authority." | fmt
            echo
            echo -e "    \033[4m-s <subject>\033[0m"
            echo    "    Full subject for a certificate (e.g. -s /C=US/CN=www.example.com)." | fmt
            echo
            echo -e "    \033[4m-u <usagebits>\033[0m"
            echo    "    Certificate usage bits. It must be one of following usages: digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign, cRLSign, encipherOnly, decipherOnly, serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, msCodeInd, msCodeCom, msCTLSign, msSGC, msEFS, or nsSGC. Additionally one can specify CA (cRLSign and keyCertSign), Server (digitalSignature, keyEncipherment, and serverAuth), Client (clientAuth), or BitLocker (1.3.6.1.4.1.311.67.1.1). If multiple usages are required, you can separate them with comma (,)." | fmt
            echo
            echo -e "    \033[4m-x\033[0m"
            echo    "    Do not use passphrase for private key." | fmt
            echo
            echo -e "    \033[4m-v\033[0m"
            echo    "    Verbose output. It can be used multiple times for greater amount of details." | fmt
            echo
            echo -e "    \033[4mfile\033[0m"
            echo    "    File name prefix to use for key and certificate." | fmt
            echo
            echo    "  DESCRIPTION"
            echo    "  Wrapper around openssl for creation of self-signed CA and certificates." | fmt
            echo
            echo    "  SAMPLES"
            echo    "  $0 -r" | fmt
            echo    "  $0 -r -b 4096 -d 30" | fmt
            echo    "  $0 -r -b 4096 -d 30 -s \"/CN=My Certificate Authority\"" | fmt
            echo    "  $0 -u Server server" | fmt
            echo    "  $0 -u Client client" | fmt
            echo    "  $0 -eu BitLocker bitlocker" | fmt
            echo
            exit 0
        ;;

        a)
            CA_CREATE=1
            CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyCertSign cRLSign"
        ;;

        b)
            if (( $OPTARG >= 1024 )) && (( $OPTARG <= 16384 )); then
                KEY_SIZE=$OPTARG
            else
                echo "Value outside of range (1024 to 16384): -b $OPTARG!" >&2
                exit 1
            fi
        ;;

        c)  CA_PREFIX="$OPTARG" ;;

        d)
            if (( $OPTARG >= 1 )) && (( $OPTARG <= 7300 )); then
                CERTIFICATE_DAYS=$OPTARG
            else
                echo "Value outside of range (1 to 7300): -d $OPTARG!" >&2
                exit 1
            fi
        ;;

        e)  EXPORT=1 ;;

        p)  CERTIFICATE_SELF=1 ;;

        r)
            CA_CREATE=1
            CA_CREATE_ROOT=1
            CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyCertSign cRLSign"
        ;;
        
        s)  CERTIFICATE_SUBJECT="$OPTARG" ;;

        u)
            TEMP_USAGES=`echo $OPTARG | tr ',' ' '`
            for TEMP_USAGE in $TEMP_USAGES; do
                TEMP_USAGE_LOWER=`echo $TEMP_USAGE | tr '[:upper:]' '[:lower:]'`
                case $TEMP_USAGE_LOWER in
                    digitalsignature) CERTIFICATE_USAGES="$CERTIFICATE_USAGES digitalSignature" ;;
                    nonrepudiation)   CERTIFICATE_USAGES="$CERTIFICATE_USAGES nonRepudiation" ;;
                    keyencipherment)  CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyEncipherment" ;;
                    dataencipherment) CERTIFICATE_USAGES="$CERTIFICATE_USAGES dataEncipherment" ;;
                    keyagreement)     CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyAgreement" ;;
                    keycertsign)      CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyCertSign" ;;
                    crlsign)          CERTIFICATE_USAGES="$CERTIFICATE_USAGES cRLSign" ;;
                    encipheronly)     CERTIFICATE_USAGES="$CERTIFICATE_USAGES encipherOnly" ;;
                    decipheronly)     CERTIFICATE_USAGES="$CERTIFICATE_USAGES decipherOnly" ;;
                    serverauth)       CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES serverAuth" ;;
                    clientauth)       CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES clientAuth" ;;
                    codesigning)      CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES codeSigning" ;;
                    emailprotection)  CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES emailProtection" ;;
                    timestamping)     CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES timeStamping" ;;
                    mscodeind)        CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES msCodeInd" ;;
                    mscodecom)        CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES msCodeCom" ;;
                    msctlsign)        CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES msCTLSign" ;;
                    mssgc)            CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES msSGC" ;;
                    msefs)            CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES msEFS" ;;
                    nssgc)            CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES nsSGC" ;;

                    ca)
                        CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyCertSign cRLSign"
                    ;;
                    server)
                        CERTIFICATE_USAGES="$CERTIFICATE_USAGES digitalSignature keyEncipherment"
                        CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES serverAuth"
                    ;;
                    client)
                        CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES clientAuth"
                    ;;
                    bitlocker)
                        CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyEncipherment"
                        CERTIFICATE_EXTENDED_USAGES="$CERTIFICATE_EXTENDED_USAGES 1.3.6.1.4.1.311.67.1.1"
                        CERTIFICATE_SUBJECT="/CN=BitLocker"
                    ;;

                    *)
                        echo "Unrecognized usage: -u $TEMP_USAGE!" >&2
                        exit 1
                    ;;
                esac
            done
        ;;

        v)  VERBOSE=$((VERBOSE + 1)) ;;

        x)  KEY_PASSPHRASE_CIPHER="" ;;

        \?)
            echo "Invalid option: -$OPTARG!" >&2
            exit 1
        ;;

        :)
            echo "Option -$OPTARG requires an argument!" >&2
            exit 1
        ;;
    esac
done


shift $(( OPTIND - 1 ))

OUTPUT_PREFIXES="$@"
OUTPUT_PREFIXES=`echo $OUTPUT_PREFIXES | tr " " "\n" | egrep -v "^$" | tr "\n" " " | sed -e 's/[[:space:]]*$//'`

if [ "$OUTPUT_PREFIXES" == "" ] ; then
    if (( $CA_CREATE_ROOT )); then
        OUTPUT_PREFIXES=ca
    else
        echo "No output files specified!" >&2
        exit 1
    fi
fi
    
CERTIFICATE_USAGES=`echo $CERTIFICATE_USAGES | tr " " "\n" | egrep -v "^$" | sort | uniq | tr "\n" " " | sed -e 's/[[:space:]]*$//'`
CERTIFICATE_EXTENDED_USAGES=`echo $CERTIFICATE_EXTENDED_USAGES | tr " " "\n" | egrep -v "^$" | sort | uniq | tr "\n" " " | sed -e 's/[[:space:]]*$//'`

if [[ "$CERTIFICATE_SUBJECT" != "" ]]; then
    if ! [[ "$CERTIFICATE_SUBJECT" =~ ^/ ]]; then
        CERTIFICATE_SUBJECT="/$CERTIFICATE_SUBJECT"
    fi
fi
        
if (( $CA_CREATE_ROOT )); then
    OUTPUT_PREFIX_COUNT=`echo $OUTPUT_PREFIXES | tr " " "\n" | wc -l`
    if (( $OUTPUT_PREFIX_COUNT > 1 )); then
        echo "Only one file is allowed when creating root certificate authority!" >&2
        exit 1
    fi
elif (( $CA_CREATE )) && (( $CERTIFICATE_SELF )); then
    echo "Cannot self-sign intermediate certificate!" >&2
    exit 1
elif ! (( $CERTIFICATE_SELF )); then
    CA_KEY_FILE=$CA_PREFIX.key
    if ! [ -a $CA_KEY_FILE ]; then
        echo "Cannot find CA key file!" >&2
        exit 1
    fi
    CA_CER_FILE=$CA_PREFIX.cer
    if ! [ -a $CA_CER_FILE ]; then
        echo "Cannot find CA certificate file!" >&2
        exit 1
    fi
fi

if [ -a /bin/openssl.exe ]; then
    OPENSSL_COMMAND=/bin/openssl.exe
else
    OPENSSL_COMMAND=openssl
fi

if [ -a /etc/ssl/openssl.cnf ]; then
    OPENSSL_CONFIG=/etc/ssl/openssl.cnf
else
    if [ -a /usr/ssl/openssl.cnf ]; then
        OPENSSL_CONFIG=/usr/ssl/openssl.cnf
    else
        echo "Cannot find default OpenSSL configuration!" >&2
        exit 1
    fi
fi

if ! (( $CA_CREATE_ROOT )) && ! (( $CERTIFICATE_SELF )); then
    $OPENSSL_COMMAND x509 -text -noout -certopt ca_default -in $CA_CER_FILE 2>/dev/null | grep "CA:TRUE" > /dev/null
    if [[ $? != 0 ]] ; then
        echo "Invalid certificate authority (no CA constraint)!" >&2
        exit 1
    fi
fi

TEMP_FILE_EXTENSIONS=$(mktemp)
ctrl_c() {
    rm -R -f $TEMP_FILE_EXTENSIONS
    exit $?
}
trap ctrl_c INT


cat $OPENSSL_CONFIG > $TEMP_FILE_EXTENSIONS
echo -e "\n[myext]" >> $TEMP_FILE_EXTENSIONS
echo "subjectKeyIdentifier=hash" >> $TEMP_FILE_EXTENSIONS
if ! (( $CA_CREATE_ROOT )) && ! (( CERTIFICATE_SELF )); then
    echo "authorityKeyIdentifier=keyid:always,issuer:always" >> $TEMP_FILE_EXTENSIONS
fi
if (( $CA_CREATE )); then
    echo "basicConstraints=CA:true" >> $TEMP_FILE_EXTENSIONS
else
    echo "basicConstraints=CA:false" >> $TEMP_FILE_EXTENSIONS
fi
if [[ "$CERTIFICATE_USAGES" != "" ]]; then
    echo "keyUsage=`echo $CERTIFICATE_USAGES | tr ' ' ','`" >> $TEMP_FILE_EXTENSIONS
fi
if [[ "$CERTIFICATE_EXTENDED_USAGES" != "" ]]; then
    echo "extendedKeyUsage=`echo $CERTIFICATE_EXTENDED_USAGES | tr ' ' ','`" >> $TEMP_FILE_EXTENSIONS
fi


for OUTPUT_PREFIX in $OUTPUT_PREFIXES; do
    KEY_FILE=$OUTPUT_PREFIX.key
    CSR_FILE=$OUTPUT_PREFIX.csr
    CER_FILE=$OUTPUT_PREFIX.cer
    P12_FILE=$OUTPUT_PREFIX.p12

    if [[ $KEY_PASSPHRASE_CIPHER != "" ]]; then
        COMMAND_KEY="$OPENSSL_COMMAND genrsa -$KEY_PASSPHRASE_CIPHER -out $KEY_FILE $KEY_SIZE"
    else
        COMMAND_KEY="$OPENSSL_COMMAND genrsa -out $KEY_FILE $KEY_SIZE"
    fi
    if (( $VERBOSE >= 2 )); then
        echo ; echo "*** $COMMAND_KEY ***"
    fi
    eval $COMMAND_KEY
    if [[ $? != 0 ]] ; then
        echo "Failed key creation!" >&2
        exit 1
    fi

    SERIAL=`$OPENSSL_COMMAND rand -hex 18`

    if (( $CA_CREATE_ROOT )) || (( $CERTIFICATE_SELF )); then

        COMMAND_CER="$OPENSSL_COMMAND req -new -x509 -key $KEY_FILE -sha256 -set_serial 0x10$SERIAL -days $CERTIFICATE_DAYS -out $CER_FILE -config $TEMP_FILE_EXTENSIONS -extensions myext"
        if [[ "$CERTIFICATE_SUBJECT" != "" ]]; then
            COMMAND_CER="$COMMAND_CER -subj \"$CERTIFICATE_SUBJECT\""
        fi
        if (( $VERBOSE >= 3 )); then
            echo ; echo "*** --- $TEMP_FILE_EXTENSIONS --- ***"
            cat $TEMP_FILE_EXTENSIONS
            echo "*** --- **"
        fi
        if (( $VERBOSE >= 2 )); then
            echo ; echo "*** $COMMAND_CER ***"
        fi
        eval $COMMAND_CER
        if [[ $? != 0 ]] ; then
            rm $KEY_FILE 2>/dev/null
            echo "Failed certificate creation!" >&2
            exit 1
        fi

    else

        COMMAND_CSR="$OPENSSL_COMMAND req -new -key $KEY_FILE -sha256 -out $CSR_FILE"
        if [[ "$CERTIFICATE_SUBJECT" != "" ]]; then
            COMMAND_CSR="$COMMAND_CSR -subj \"$CERTIFICATE_SUBJECT\""
        fi
        if (( $VERBOSE >= 2 )); then
            echo ; echo "*** $COMMAND_CSR ***"
        fi
        eval $COMMAND_CSR
        if [[ $? != 0 ]] ; then
            rm $KEY_FILE 2>/dev/null
            echo "Failed certificate signing request creation!" >&2
            exit 1
        fi

        COMMAND_CER="$OPENSSL_COMMAND x509 -req -CA $CA_CER_FILE -CAkey $CA_KEY_FILE -set_serial 0x10$SERIAL -days $CERTIFICATE_DAYS -in $CSR_FILE -out $CER_FILE -extfile $TEMP_FILE_EXTENSIONS -extensions myext"
        if (( $VERBOSE >= 3 )); then
            echo ; echo "*** --- $TEMP_FILE_EXTENSIONS --- ***"
            cat $TEMP_FILE_EXTENSIONS
            echo "*** --- ***"
        fi
        if (( $VERBOSE >= 2 )); then
            echo ; echo "*** $COMMAND_CER ***"
        fi
        eval $COMMAND_CER
        if [[ $? != 0 ]] ; then
            rm $KEY_FILE 2>/dev/null
            echo "Failed certificate creation!" >&2
            exit 1
        fi

    fi

    if (( $VERBOSE )); then
        COMMAND_DET="$OPENSSL_COMMAND x509 -text -serial -fingerprint -in $CER_FILE"
        if (( $VERBOSE >= 2 )); then
            echo ; echo "*** $COMMAND_DET ***"
        fi
        echo
        eval $COMMAND_DET
    fi

    if (( $EXPORT )); then
        COMMAND_EXP="$OPENSSL_COMMAND pkcs12 -export -in $CER_FILE -inkey $KEY_FILE -out $P12_FILE"
        if (( $VERBOSE >= 2 )); then
            echo ; echo "*** $COMMAND_EXP ***"
        fi
        echo
        eval $COMMAND_EXP
    fi
done


rm -R -f $TEMP_FILE_EXTENSIONS

exit 0
