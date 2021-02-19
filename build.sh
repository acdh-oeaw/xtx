pushd xsl-tokenizer
git pull
popd

ant

podman container stop xtx
podman container rm xtx
podman build --tag xtx .
podman container run --publish 8080:8080 --detach --name xtx xtx --mount type=bind,source=/mnt/jwv-fs,destination=/

