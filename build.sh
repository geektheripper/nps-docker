#!/usr/bin/env bash

latest_release_version() {
  wget -qO- "https://api.github.com/repos/cnlh/nps/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' |
    sed -E 's/^v//'
}

nps_version=$(latest_release_version)

docker build \
  --tag "geektr/nps:$nps_version" \
  --tag "geektr/nps:latest" \
  --build-arg nps_version="$nps_version" \
  --compress \
  .

tee <<EOF
=========================
docker push geektr/nps
=========================
EOF
