# Rundeck Development Environment

## Start Rundeck

```
cd ~/rundeck-dev-environment
make run-rundeck
```

Login
* http://127.0.0.1:4440
* admin / admin

Settings
* http://127.0.0.1:4440/menu/systemConfig
* http://127.0.0.1:4440/menu/systemInfo

## Install Rundeck CLI

```
cd ~/rundeck-dev-environment
make install-rd-cli
```

## Dev Instructions

* If your rundeck jobs requires any input data: Files go here -> `input_data`
* Current Configuration:
  * See `Makefile -> copy-files`
  * Files in `input_data` will be copied to `tmp` on each job execution by `make run-job`
  * The `tmp`-Directory will be cleaned up before

## Execute a Rundeck Jobs

```
cd ~/rundeck-dev-environment
make run-job
```

## Further Infos

### Rundeck Tutorials

https://rundeck.org/docs/tutorials/index.html

### CLI

* https://github.com/rundeck/rundeck-cli
  * https://github.com/rundeck/rundeck-cli/releases
* https://rundeck.github.io/rundeck-cli/
  * https://rundeck.github.io/rundeck-cli/install/

### Rundeck with Docker

#### Docker-Hub

* https://hub.docker.com/r/rundeck/rundeck/

#### Rundeck-Zoo

* https://rundeck.org/docs/administration/install/docker.html
* https://github.com/rundeck/docker-zoo
