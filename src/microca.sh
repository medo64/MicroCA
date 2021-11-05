#!/bin/bash
COMMAND_LINE="$0 $*"
VERSION=1.2.3

KEY_ECC=0
KEY_SIZE=""
KEY_SIZE_RSA_DEFAULT="2048"
KEY_SIZE_ECC_DEFAULT="256"
KEY_PASSPHRASE_CIPHER="aes256"
SIGNATURE_DIGEST="sha256"
SIGNATURE_DIGEST_FORCED=0

CA_PREFIX="ca"
CA_CREATE=0
CA_CREATE_ROOT=0

CERTIFICATE_DAYS=3650
CERTIFICATE_DAYS_FORCED=0
CERTIFICATE_USAGES=""
CERTIFICATE_EXTENDED_USAGES=""
CERTIFICATE_SUBJECT=""
CERTIFICATE_SELF=0
CERTIFICATE_ALT_DNS=()
CERTIFICATE_ALT_IP=()
CERTIFICATE_ALT_EMAIL=()

CERTIFICATE_ONLY_CSR=0
CERTIFICATE_RETAIN_CSR=0

EXPORT=0
VERBOSE=0
OUTPUT_PREFIXES=""

if [ -t 1 ]; then
    ESCAPE_RESET="\E[0m"
    ESCAPE_UNDERLINE="\E[4m"
    ESCAPE_VERBOSE="\E[34;1m"
fi

while getopts ":ab:c:d:eg:hi:m:n:pqrs:tTu:vVx" OPT; do
    case $OPT in
        h)
            echo
            echo    "  SYNOPSIS"
            echo -e "  `echo $0 | xargs basename` [${ESCAPE_UNDERLINE}-a${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-b <numbits>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-c <fileprefix>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-d <days>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-e${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-g <digest>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-i <ipaddress>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-m <email>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-n <dnsname>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-p${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-q${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-r${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-s <subject>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-t${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-T${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-u <usagebits>${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-v${ESCAPE_RESET}] [${ESCAPE_UNDERLINE}-x${ESCAPE_RESET}] ${ESCAPE_UNDERLINE}fileprefix${ESCAPE_RESET}" | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-a${ESCAPE_RESET}"
            echo    "    Marks certificate as certificate authority." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-b <numbits>${ESCAPE_RESET}"
            echo    "    Number of bits to use for key. RSA keys can be between 1024 and 16384 bits (2048 default) while ECC keys can be either 256 (secp256r1/prime256v1; default), 384 (secp384r1) or 521 (secp521r1) bits." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-c <fileprefix>${ESCAPE_RESET}"
            echo    "    Prefix for CA (default value is ca)." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-d <days>${ESCAPE_RESET}"
            echo    "    Number of days certificate is valid for. Default value is 3650 days." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-e${ESCAPE_RESET}"
            echo    "    Uses ECC algorithm instead of RSA for private key generation." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-g <digest>${ESCAPE_RESET}"
            echo    "    Digest algorithm. Allowed values are sha256, sha384, and sha512. Default value is sha256." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-i <ipaddress>${ESCAPE_RESET}"
            echo    "    IP address to add into subjectAltName extension. Can be repeated multiple times." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-m <email>${ESCAPE_RESET}"
            echo    "    E-mail address to add into subjectAltName extension. Can be repeated multiple times." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-n <dnsname>${ESCAPE_RESET}"
            echo    "    DNS name to add into subjectAltName extension. Can be repeated multiple times." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-p${ESCAPE_RESET}"
            echo    "    Creates a self-signed end entity certificate, i.e. no certificate authority is used." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-q${ESCAPE_RESET}"
            echo    "    Do not use passphrase for private key." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-r${ESCAPE_RESET}"
            echo    "    Creates a self-signed root certificate authority. Unless otherwise specified key length will be 4096 for RSA keys (384 for ECC) and digest algorithm will be sha384. Key will be valid for 7300 days." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-s <subject>${ESCAPE_RESET}"
            echo    "    Full subject for a certificate (e.g. -s /C=US/CN=www.example.com)." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-t${ESCAPE_RESET}"
            echo    "    Generate only CSR." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-T${ESCAPE_RESET}"
            echo    "    Retain CSR after creating a request." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-u <usagebits>${ESCAPE_RESET}"
            echo    "    Certificate usage bits. It must be one of following usages: digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign, cRLSign, encipherOnly, decipherOnly, serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, msCodeInd, msCodeCom, msCTLSign, msSGC, msEFS, or nsSGC. Additionally one can specify CA (cRLSign and keyCertSign), Server (digitalSignature, keyEncipherment, and serverAuth), Client (clientAuth), or BitLocker (keyEncipherment and 1.3.6.1.4.1.311.67.1.1). If multiple usages are required, you can separate them with comma (,)." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-v${ESCAPE_RESET}"
            echo    "    Verbose output. It can be used multiple times for greater amount of details." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}-x${ESCAPE_RESET}"
            echo    "    Exports the resulting key as PKCS12 file." | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}fileprefix${ESCAPE_RESET}"
            echo    "    File name prefix to use for key and certificate." | fmt
            echo
            echo    "  DESCRIPTION"
            echo    "  Wrapper around openssl for creation of self-signed CA and certificates." | fmt
            echo
            echo    "  EXAMPLES"
            echo    "  $0 -r" | fmt
            echo    "  $0 -re" | fmt
            echo    "  $0 -r -b 4096" | fmt
            echo    "  $0 -r -b 4096 -s \"CN=My Root CA\"" | fmt
            echo    "  $0 -a -b 2048 -s \"CN=My Intermediate CA\"" inter-ca | fmt
            echo    "  $0 -p -b 1024 -s \"CN=My Test\" test" | fmt
            echo    "  $0 -p -b 1024 -s \"CN=My Test\" -i 127.0.0.1 -n localhost test" | fmt
            echo    "  $0 -u Server -s \"CN=My Server\" myServer" | fmt
            echo    "  $0 -u Client -s \"CN=My Client\" myClient" | fmt
            echo    "  $0 -u BitLocker -x myBitocker" | fmt
            echo
            echo    "  AUTHOR"
            echo    "  Josip Medved"
            echo    "  www.medo64.com"
            exit 0
        ;;

        a)
            CA_CREATE=1
            CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyCertSign cRLSign"
        ;;

        b)  KEY_SIZE=$OPTARG ;;

        c)  CA_PREFIX="$OPTARG" ;;

        d)
            if (( $OPTARG >= 1 )) && (( $OPTARG <= 7300 )); then
                CERTIFICATE_DAYS=$OPTARG
            else
                echo "Value outside of range (1 to 7300): -d $OPTARG!" >&2
                exit 1
            fi
            CERTIFICATE_DAYS_FORCED=1
        ;;

        e)  KEY_ECC=1 ;;

        g)
            TEMP_DIGEST_LOWER=`echo $OPTARG | tr '[:upper:]' '[:lower:]'`
            case $TEMP_DIGEST_LOWER in
                sha256) SIGNATURE_DIGEST=$TEMP_DIGEST_LOWER ;;
                sha384) SIGNATURE_DIGEST=$TEMP_DIGEST_LOWER ;;
                sha512) SIGNATURE_DIGEST=$TEMP_DIGEST_LOWER ;;

                *)
                    echo "Unrecognized digest algorithm: -g $OPTARG!" >&2
                    exit 1
                ;;
            esac
            SIGNATURE_DIGEST_FORCED=1
        ;;

        i)  CERTIFICATE_ALT_IP+=("$OPTARG") ;;

        m)  CERTIFICATE_ALT_EMAIL+=("$OPTARG") ;;

        n)  CERTIFICATE_ALT_DNS+=("$OPTARG") ;;

        p)  CERTIFICATE_SELF=1 ;;

        q)  KEY_PASSPHRASE_CIPHER="" ;;

        r)
            CA_CREATE=1
            CA_CREATE_ROOT=1
            KEY_SIZE_ECC_DEFAULT=384;
            KEY_SIZE_RSA_DEFAULT=4096;
            CERTIFICATE_USAGES="$CERTIFICATE_USAGES keyCertSign cRLSign"
            if ! (( $SIGNATURE_DIGEST_FORCED )); then SIGNATURE_DIGEST=sha384; fi
            if ! (( $CERTIFICATE_DAYS_FORCED )); then CERTIFICATE_DAYS=7300; fi
        ;;

        s)  CERTIFICATE_SUBJECT="$OPTARG" ;;

        t)  CERTIFICATE_ONLY_CSR=1 ;;

        T)  CERTIFICATE_RETAIN_CSR=1 ;;

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

        V)
            echo "MicroCA $VERSION"
            exit 0
        ;;

        x)  EXPORT=1 ;;

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


if (( $KEY_ECC )); then
    if [[ "$KEY_SIZE" == "" ]]; then KEY_SIZE=$KEY_SIZE_ECC_DEFAULT; fi
    if (( $KEY_SIZE != 256 )) && (( $KEY_SIZE != 384 )) && (( $KEY_SIZE != 521 )); then
        echo "Value outside of range (256, 384, or 521) for ECC key: -b $KEY_SIZE." >&2
        echo "Using default ECC key size ($KEY_SIZE_ECC_DEFAULT)." >&2
        KEY_SIZE=$KEY_SIZE_ECC_DEFAULT
    fi
else
    if [[ "$KEY_SIZE" == "" ]]; then KEY_SIZE=$KEY_SIZE_RSA_DEFAULT; fi
    if (( $KEY_SIZE < 1024 )) || (( $KEY_SIZE > 16384 )); then
        echo "Value outside of range (1024 to 16384) for RSA key: -b $KEY_SIZE." >&2
        echo "Using default RSA key size ($KEY_SIZE_RSA_DEFAULT)." >&2
        KEY_SIZE=$KEY_SIZE_RSA_DEFAULT
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
elif ! (( $CERTIFICATE_SELF )) && ! (( $CERTIFICATE_ONLY_CSR )); then
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

if (( $CA_CREATE_ROOT )) || (( $CA_CREATE )); then
    if (( $CERTIFICATE_ONLY_CSR )); then
        echo "No CSR can be created for CA!" >&2
        exit 1
    fi
fi

if (( $CERTIFICATE_ONLY_CSR )) && !(( $CERTIFICATE_RETAIN_CSR )); then
    echo "Certificate signing request will be retained as only CSR is produced." >&2
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

if ! (( $CA_CREATE_ROOT )) && ! (( $CERTIFICATE_SELF )) && ! (( $CERTIFICATE_ONLY_CSR )); then
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
if (( $CA_CREATE )) || (( CERTIFICATE_SELF )); then
    echo "authorityKeyIdentifier=keyid:always,issuer" >> $TEMP_FILE_EXTENSIONS
else
    echo "authorityKeyIdentifier=keyid,issuer" >> $TEMP_FILE_EXTENSIONS
fi
if (( $CA_CREATE )); then
    echo "basicConstraints=critical,CA:true" >> $TEMP_FILE_EXTENSIONS
else
    echo "basicConstraints=CA:false" >> $TEMP_FILE_EXTENSIONS
fi
if [[ "$CERTIFICATE_USAGES" != "" ]]; then
    if (( $CA_CREATE )); then
        echo "keyUsage=critical,`echo $CERTIFICATE_USAGES | tr ' ' ','`" >> $TEMP_FILE_EXTENSIONS
    else
        echo "keyUsage=`echo $CERTIFICATE_USAGES | tr ' ' ','`" >> $TEMP_FILE_EXTENSIONS
    fi
fi
if [[ "$CERTIFICATE_EXTENDED_USAGES" != "" ]]; then
    echo "extendedKeyUsage=`echo $CERTIFICATE_EXTENDED_USAGES | tr ' ' ','`" >> $TEMP_FILE_EXTENSIONS
fi
if (( $CA_CREATE )); then
    sed -i "/\\[ req_distinguished_name \\]/a commonName_default=`hostname` CA" $TEMP_FILE_EXTENSIONS
else
    sed -i "/\\[ req_distinguished_name \\]/a commonName_default=`hostname`" $TEMP_FILE_EXTENSIONS
fi

if (( ${#CERTIFICATE_ALT_DNS[@]} > 0 )) || (( ${#CERTIFICATE_ALT_IP[@]} > 0 )) || (( ${#CERTIFICATE_ALT_EMAIL[@]} > 0 )); then
    echo "subjectAltName=@alt_section" >> $TEMP_FILE_EXTENSIONS
    echo >> $TEMP_FILE_EXTENSIONS
    echo "[alt_section]" >> $TEMP_FILE_EXTENSIONS
    for (( i=0; i<${#CERTIFICATE_ALT_DNS[@]}; i++)); do
        echo "DNS.$((i+1))=${CERTIFICATE_ALT_DNS[$i]}" >> $TEMP_FILE_EXTENSIONS
    done
    for (( i=0; i<${#CERTIFICATE_ALT_IP[@]}; i++)); do
        echo "IP.$((i+1))=${CERTIFICATE_ALT_IP[$i]}" >> $TEMP_FILE_EXTENSIONS
    done
    for (( i=0; i<${#CERTIFICATE_ALT_EMAIL[@]}; i++)); do
        echo "email.$((i+1))=${CERTIFICATE_ALT_EMAIL[$i]}" >> $TEMP_FILE_EXTENSIONS
    done
fi


for OUTPUT_PREFIX in $OUTPUT_PREFIXES; do
    KEY_FILE=$OUTPUT_PREFIX.key
    CSR_FILE=$OUTPUT_PREFIX.csr
    CER_FILE=$OUTPUT_PREFIX.cer
    P12_FILE=$OUTPUT_PREFIX.p12

    if (( $KEY_ECC )); then
        COMMAND_KEY="$OPENSSL_COMMAND ecparam -genkey"
        case $KEY_SIZE in
            256) COMMAND_KEY="$COMMAND_KEY -name prime256v1" ;;
            384) COMMAND_KEY="$COMMAND_KEY -name secp384r1" ;;
            521) COMMAND_KEY="$COMMAND_KEY -name secp521r1" ;;
            *)
                echo "Unrecognized key size for ECC: -b $KEY_SIZE!" >&2
                exit 1
            ;;
        esac
        if [[ $KEY_PASSPHRASE_CIPHER != "" ]]; then
            COMMAND_KEY="$COMMAND_KEY -noout | $OPENSSL_COMMAND ec -$KEY_PASSPHRASE_CIPHER -out $KEY_FILE"
        else
            COMMAND_KEY="$COMMAND_KEY -out $KEY_FILE"
        fi
    else
        if [[ $KEY_PASSPHRASE_CIPHER != "" ]]; then
            COMMAND_KEY="$OPENSSL_COMMAND genrsa -$KEY_PASSPHRASE_CIPHER -out $KEY_FILE $KEY_SIZE"
        else
            COMMAND_KEY="$OPENSSL_COMMAND genrsa -out $KEY_FILE $KEY_SIZE"
        fi
    fi
    if (( $VERBOSE >= 2 )); then
        echo ; echo -e "${ESCAPE_VERBOSE}*** $COMMAND_KEY ***${ESCAPE_RESET}"
    fi
    eval $COMMAND_KEY
    if [[ $? != 0 ]] ; then
        echo "Failed key creation!" >&2
        exit 1
    fi

    SERIAL=`$OPENSSL_COMMAND rand -hex 19`

    if (( $VERBOSE >= 3 )); then
        echo ; echo -e "${ESCAPE_VERBOSE}*** --- $TEMP_FILE_EXTENSIONS --- ***${ESCAPE_RESET}"
        cat $TEMP_FILE_EXTENSIONS
        echo "*** --- **"
    fi

    if (( $CA_CREATE_ROOT )) || (( $CERTIFICATE_SELF )); then

        COMMAND_CER="$OPENSSL_COMMAND req -new -x509 -key $KEY_FILE -$SIGNATURE_DIGEST -set_serial 0x42$SERIAL -days $CERTIFICATE_DAYS -out $CER_FILE -config $TEMP_FILE_EXTENSIONS -extensions myext"
        if [[ "$CERTIFICATE_SUBJECT" != "" ]]; then
            COMMAND_CER="$COMMAND_CER -subj \"$CERTIFICATE_SUBJECT\""
        fi
        if (( $VERBOSE >= 2 )); then
            echo ; echo -e "${ESCAPE_VERBOSE}*** $COMMAND_CER ***${ESCAPE_RESET}"
        fi
        eval $COMMAND_CER
        if [[ $? != 0 ]] ; then
            rm $KEY_FILE 2>/dev/null
            echo "Failed certificate creation!" >&2
            exit 1
        fi

    else

        COMMAND_CSR="$OPENSSL_COMMAND req -new -key $KEY_FILE -$SIGNATURE_DIGEST -out $CSR_FILE -config $TEMP_FILE_EXTENSIONS -extensions myext"
        if [[ "$CERTIFICATE_SUBJECT" != "" ]]; then
            COMMAND_CSR="$COMMAND_CSR -subj \"$CERTIFICATE_SUBJECT\""
        fi
        if (( $VERBOSE >= 2 )); then
            echo ; echo -e "${ESCAPE_VERBOSE}*** $COMMAND_CSR ***${ESCAPE_RESET}"
        fi
        eval $COMMAND_CSR
        if [[ $? != 0 ]] ; then
            rm $KEY_FILE 2>/dev/null
            echo "Failed certificate signing request creation!" >&2
            exit 1
        fi

        if (( $CERTIFICATE_ONLY_CSR )); then continue; fi

        COMMAND_CER="$OPENSSL_COMMAND x509 -req -CA $CA_CER_FILE -CAkey $CA_KEY_FILE -set_serial 0x42$SERIAL -days $CERTIFICATE_DAYS -in $CSR_FILE -out $CER_FILE -extfile $TEMP_FILE_EXTENSIONS -extensions myext"
        if (( $VERBOSE >= 2 )); then
            echo ; echo -e "${ESCAPE_VERBOSE}*** $COMMAND_CER ***${ESCAPE_RESET}"
        fi
        eval $COMMAND_CER
        if [[ $? != 0 ]] ; then
            rm $KEY_FILE 2>/dev/null
            echo "Failed certificate creation!" >&2
            exit 1
        fi

        if !(( $CERTIFICATE_RETAIN_CSR )); then
            rm $CSR_FILE
        fi
    fi

    if (( $VERBOSE )); then
        COMMAND_DET="$OPENSSL_COMMAND x509 -text -serial -fingerprint -in $CER_FILE"
        if (( $VERBOSE >= 2 )); then
            echo ; echo -e "${ESCAPE_VERBOSE}*** $COMMAND_DET ***${ESCAPE_RESET}"
        fi
        echo
        eval $COMMAND_DET
    fi

    if (( $EXPORT )); then
        COMMAND_EXP="$OPENSSL_COMMAND pkcs12 -export -in $CER_FILE -inkey $KEY_FILE -out $P12_FILE"
        if (( $VERBOSE >= 2 )); then
            echo ; echo -e "${ESCAPE_VERBOSE}*** $COMMAND_EXP ***${ESCAPE_RESET}"
        fi
        echo
        eval $COMMAND_EXP
    fi
done


rm -R -f $TEMP_FILE_EXTENSIONS

exit 0
