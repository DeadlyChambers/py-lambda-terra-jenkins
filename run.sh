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
#aws configure import --csv file:///home/shane/tmp/jenkins-deployer.csv
#AWS_PROFILE=jenkins-deployer
terraform init
terraform apply -auto-approve -var created="script"
cd ..

tput setaf 2
printf "\nInvoke Lambda from cli\n"
tput setaf 9
aws lambda invoke --function-name "ds-operations-lambda-sns" "response.json"


tput setaf 2
cat response.json
tput blink
printf '\nComplete\n'
tput setaf 9