# Health checker incident docker

This repository provides a docker container environment for [health-checker-inciden](https://github.com/tonicforhealth/health-checker-incident).

## Interface ports 
- HTTP 80 REST API for webhook 
- HTTP 8080 REST API for incident fire

## Run of health-checker-incident with docker-compose
------------

```bash
git clone git@github.com:tonicforhealth/health-checker-incident-docker.git
cd health-checker-incident-docker
cp config/parameters.default.yml config/parameters.yml
vi config/parameters.yml # set up right config
docker-compose up -d incident-web
```