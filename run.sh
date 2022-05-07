#!/bin/bash
tput setaf 2
printf "Package App Code\n"
tput setaf 9

cd lambda || return
pipenv run python3 package.py

tput setaf 2
printf "\nDeploy with Terraform\n"
tput setaf 9
cd ../terraform || return
##Create an access key, and you can import it to aws config
#aws configure import --csv file:///home/shane/tmp/jenkins-deployer.csv
terraform init
terraform apply -auto-approve -var created="script"
function_name=$(terraform output function_name)
cd ..

tput setaf 2
printf "\nInvoke Lambda from cli\n"
tput setaf 9

aws lambda invoke --function-name $function_name response.json


tput setaf 2
cat response.json
tput blink
printf '\nComplete\n'
tput setaf 9