#!/bin/bash

SCRIPT_NAME=`basename $0`
if [ -t 1 ]; then
    ESCAPE_RESET="\E[0m"
    ESCAPE_UNDERLINE="\E[4m"
fi

while getopts ":h" OPT
do
    case $OPT in
        h)
            echo
            echo    "  SYNOPSIS"
            echo -e "  $SCRIPT_NAME ${ESCAPE_UNDERLINE}version${ESCAPE_RESET}" | fmt
            echo
            echo -e "    ${ESCAPE_UNDERLINE}version${ESCAPE_RESET}"
            echo    "    Version in form of MAJOR.MINOR." | fmt
            echo
            echo    "  DESCRIPTION"
            echo    "  Creates debian package with assigned version." | fmt
            echo
            echo    "  SAMPLES"
            echo    "  $SCRIPT_NAME 1.0" | fmt
            echo
            exit 0
        ;;

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

if [[ "$2" != "" ]]
then
    echo "Too many arguments!" >&2
    exit 1
fi

RELEASE_MAJOR=`echo -n $1 | cut -d. -f1`
RELEASE_MINOR=`echo -n $1 | cut -d. -f2-`

if [[ ! $RELEASE_MAJOR =~ ^[0-9]+$ ]] || [[ ! $RELEASE_MINOR =~ ^[0-9]+$ ]]
then
    echo "Unrecognized version format ($MAJOR.$MINOR)!" >&2
    exit 1
fi


if [[ ! "$(uname -a)" =~ "GNU/Linux" ]]
then
    echo "Must run under Linux!" >&2
    exit 1
fi

which dpkg-deb &> /dev/null
if [ ! $? -eq 0 ]
then
    echo "Package dpkg-deb not installed!" >&2
    exit 1
fi


DIRECTORY_ROOT=`mktemp -d`

terminate() {
    rm -R $DIRECTORY_ROOT 2> /dev/null
}
trap terminate INT EXIT


if [ "$EUID" -ne 0 ]
then
    echo "Must run as root (try sudo)!" >&2
    exit 1
fi


DIRECTORY_RELEASE="../releases"

RELEASE_ARCHITECTURE=`grep "Architecture:" ./DEBIAN/control | sed "s/Architecture://" | sed "s/[^a-z]//g"`

PACKAGE_NAME="microca_${RELEASE_MAJOR}.${RELEASE_MINOR}_${RELEASE_ARCHITECTURE}"
DIRECTORY_PACKAGE="$DIRECTORY_ROOT/$PACKAGE_NAME"


mkdir $DIRECTORY_PACKAGE
cp -R ./DEBIAN $DIRECTORY_PACKAGE/

mkdir -p $DIRECTORY_PACKAGE/opt/microca
cp ../src/microca.sh $DIRECTORY_PACKAGE/opt/microca/microca
if [ ! $? -eq 0 ]
then
    echo "Cannot extract archive!" >&2
    exit 1
fi

find $DIRECTORY_PACKAGE -type d -exec chmod 755 {} +
find $DIRECTORY_PACKAGE -type f -exec chmod 644 {} +
chmod 755 $DIRECTORY_PACKAGE/DEBIAN/*inst 2>/dev/null
chmod 755 $DIRECTORY_PACKAGE/DEBIAN/*rm 2>/dev/null
chmod 755 $DIRECTORY_PACKAGE/opt/microca/microca

sed -i "s/MAJOR/$RELEASE_MAJOR/" $DIRECTORY_PACKAGE/DEBIAN/control
sed -i "s/MINOR/$RELEASE_MINOR/" $DIRECTORY_PACKAGE/DEBIAN/control

dpkg-deb --build $DIRECTORY_PACKAGE > /dev/null

cp $DIRECTORY_ROOT/$PACKAGE_NAME.deb $DIRECTORY_RELEASE/
if [ $? -eq 0 ]
then
    echo "Package $DIRECTORY_RELEASE/$PACKAGE_NAME.deb successfully created." >&2
else
    echo "Didn't find output Debian package!" >&2
    exit 1
fi
