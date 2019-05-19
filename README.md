# NPS Docker Image

## What is nps

to know more about nps, visit https://github.com/cnlh/nps

## how to use this image

a config file is necessary for this image, you can [read the doc](https://github.com/cnlh/nps/blob/master/README.md) to know how to write it.

### start a nps server

```shell
$ docker run -d --network=host -v /path/to/nps.conf:/etc/nps-docker/nps.conf:ro geektr/nps
## `--network=host` means the docker container run on host network
```

### start a nps client

```shell
$ docker run -d --network=host -v /path/to/npc.conf:/etc/nps-docker/npc.conf:ro geektr/nps
## `--network=host` means the docker container run on host network
```

### nps mode

this image can run as both nps server and nps client
what it will run depends on environment variables and config file

``` shell
# /somepath/
# └── config
#     ├── npc.conf
#     └── nps.conf

# first, it depends depend on config file

$ docker run -d --network=host -v /somepath/config/nps.conf:/etc/nps-docker/nps.conf:ro geektr/nps
# => server

$ docker run -d --network=host -v /somepath/config/npc.conf:/etc/nps-docker/npc.conf:ro geektr/nps
# => client

$ docker run -d --network=host -v /somepath/config:/etc/nps-docker:ro geektr/nps
# => both server and client

# you can pass an enviroment variable 'NPS_MODE' to force what it run, 'NPS_MODE' can be set to 'npc', 'nps-client', 'nps', 'nps-server' and 'both'
$ docker run -d --network=host --env NPS_MODE=nps -v /somepath/config:/etc/nps-docker:ro geektr/nps
# => server

$ docker run -d --network=host \
 --env NPS_SERVER=xxx.xxx.xxx.xxx:xxxx\
 --env NPS_VKEY=xxxxxxxxxxxxxxxx \
 --env NPS_TYPE=tcp \
 geektr/nps
# => client
```

## with docker compose

when this image runs, it will replace all shell-style variables to their environment value, this feature may helps in auto deploy and authority control.

### a npc server example

docker-compose.yml

```yml
version: '3'
services:
  nps_server:
    image: geektr/nps
    environment:
      - APPNAME=${APPNAME}
      - PUBLIC_VKEY=${PUBLIC_VKEY}
    restart: always
    network_mode: "host"
    volumes:
      - ./nps.conf:/etc/nps-docker/nps.conf:ro
```

nps.conf

```conf
appname = ${APPNAME}
...
public_vkey = ${PUBLIC_VKEY}
...
```

.env

```env
APPNAME=mynps
PUBLIC_VKEY=xxxxxxxxxxxxxxxx
```

### a nps client example

tips: the `local_ip` field can be filled with hostname, so you can use `container_name` in `npc.conf`

docker-compose.yml

```yml
version: '3'
services:
  web_server:
    image: nginx
    container_name: web_server
    expose:
      - "80"
      - "443"
  nps_client:
    image: geektr/nps
    environment:
      - NPS_SERVER_ADDR=${HOST_IP}
      - NPS_PRIVILEGE_TOKEN=${NPS_TOKEN}
    restart: always
    volumes:
      - ./npc.conf:/etc/nps-docker/npc.conf:ro
```

npc.conf

```conf
[common]
server_addr=${NPS_SERVER_ADDR}
vkey=${VKEY}

[https]
mode=tcp
target_addr=web_server:443
server_port=443

[http]
mode=tcp
target_addr=web_server:80
server_port=80
```

.env

```env
NPS_SERVER_ADDR=xxx.xxx.xxx.xxx:xxxx
VKEY=xxxxxxxxxxxxxxxx
```
