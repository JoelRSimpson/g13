#!/usr/bin/env bash

function build_g13d {
    #create g13d binary
    echo "creating g13d binary ..."
    git clone https://github.com/ecraven/g13.git "$BUILD_G13D"
    cd "$BUILD_G13D"
    make && cp "$BUILD_G13D/g13d" "$BUILD/g13d"
    cd "$PROJECT"
}

PROJECT=`pwd`
SRC="$PROJECT/src"
BUILD="$PROJECT/build"
BUILD_G13D="$BUILD/g13d.git"

if [ -d  "$BUILD" ]
then
    echo "overwriting existing build in $BUILD ..."
else
    mkdir -p "$BUILD/etc"
fi


if [ -d  "$BUILD_G13D" ]
then
    echo "using existing g13d from $BUILD_G13D ..."
else
    echo "downloading and building g13d ..."
    build_g13d
fi


#copy resources from src to build
echo "copying scripts and resources ..."
cp "$SRC"/g13d-* "$BUILD"/
cp "$SRC"/*.bind "$BUILD"/etc/