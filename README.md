# [Jenkins](https://datassential.atlassian.net/wiki/spaces/ENG/pages/1482457116/Jenkins)
I will be using the alias k for kubectl, `k version` to see if you already have the alias
[k8s jenkins concepts](https://www.infoq.com/articles/scaling-docker-with-kubernetes/)

## [Setting up minikube](k8s-setup/README.md)
Following the readme will setup Jenkins using k8s, and helm on ubuntu-wsl

## [Lambda Function package and deploy](lambda/README.md)
Running the run.sh script will package the python code into a zip, and then
use terraform to deploy it
```
sh run.sh
```

TODO: Look into [version python](https://github.com/pypa/sampleproject/blob/main/setup.py)