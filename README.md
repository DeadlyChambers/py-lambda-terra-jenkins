# [Jenkins](https://datassential.atlassian.net/wiki/spaces/ENG/pages/1482457116/Jenkins)
I will be using the alias k for kubectl, `k version` to see if you already have the alias
[k8s jenkins concepts](https://www.infoq.com/articles/scaling-docker-with-kubernetes/)

## [Setup Locally on Minikube](https://www.jenkins.io/doc/book/installing/kubernetes)
I wanted to start with Jenkins created using K8s, so locally I'm using Minikube. Since this is the first time for me running Minikube on my box it didn't initially start because it had an issue connecting to the Docker daemon at unix:///var/run/docker.sock

Running `sudo dockerd` once the service was finished initializing, opening a new terminal and `minikube start` worked. After restarting minikube it still works. I'll need to test what happens when I restart. Since I'm working off WSL systemd doesn't appear to work as it would on it's own machine/vm


**Create Volume and Service Account**
```
k apply -f k8s-setup/jenkins-volume.yaml
k apply -f k8s-setup/jenkins-sa.yaml
```

**Install via helm**
```
chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f jenkins-values.yaml $chart
```

```
minikube ssh
sudo chown -R 1000:1000 /data/jenkins-volume
```
Notes for configuration 
Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http:///configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/

```
jsonpath="{.data.jenkins-admin-password}";
secret=$(k get secret -n jenkins jenkins -o jsonpath=$jsonpath);
echo $(echo $secret | base64 --decode);
jsonpath="{.spec.ports[0].nodePort}"
NODE_PORT=$(k get -n jenkins -o jsonpath=$jsonpath services jenkins)
jsonpath="{.items[0].status.addresses[0].address}"
NODE_IP=$(k get nodes -n jenkins -o jsonpath=$jsonpath)
echo http://$NODE_IP:$NODE_PORT/login
```

Setup port forwarding if not running on cluster
```
podname=$(k get pods -n jenkins -o name | awk -F "/" '{print $2}')
k -n jenkins port-forward "${podname}" 8080:8080
echo http://127.0.0.1:8080/login
```

## Connecting repo
### Option 1
```

```

### Option 2
I am using [gogs](https://gogs.io/docs/installation/install_from_binary)
```
minikube ssh
docker pull gogs/gogs
mkdir -p ~/gogs-data/gogs
docker run -d --name=gogs -p 10022:22 -p 3000:3000 -v ~/gogs-data/gogs:/data gogs/gogs
# open http://localhost:3000 create a new account, 
# create a repo, and push the lambda code
k -n jenkins port-forward "${podname}" 3000:3000
```
