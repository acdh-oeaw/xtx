# we assume that eXist has been mounted via webdav to the host system, adjust $EXIST_MOUNTPOINT accordingly
EXIST_MOUNTPOINT="/run/user/1000/gvfs/dav:host=localhost,port=8080,ssl=false,prefix=%2Fexist%2Fwebdav%2Fdb/apps/xtx"
TARGET=`pwd`
pushd $EXIST_MOUNTPOINT
pwd

cp *.html $TARGET
cp *.xml $TARGET
cp *.xql $TARGET
cp *. $TARGET
cp -r * $TARGET
popd
