#!/bin/bash
_format_vol=1
[[ -z "$1" ]] && _format_vol=0
#_volume=/dev/xvdb #xvdb

JENKINS_HOME=/var/lib/jenkins
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
apt update -y
apt install default-jdk -y
echo "
export JENKINS_HOME=${JENKINS_HOME}
export JAVA_HOME=${JAVA_HOME}" > /etc/profile.d/jenkins.sh
source /etc/profile.d/jenkins.sh
#sudo lsblk 
#file -s /dev/xvdb

# this will wipe the volume nothing was passed to the command
# assuming we are using a snaphot, we can skip the formatting of
# the ebs volume

# if you don't have mkfs yum install xfsprogs
apt update -y
if ! command -v jenkins &> /dev/null ; 
    sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
    then apt install jenkins -y ; 
fi
cat "${JENKINS_HOME}/secrets/initialAdminPassword"
# if [[ -f "$_JENKINS_HOME/jenkins.war" ]]; 
#     then
#         #Jenkins already exists on the volume, so you could do
#         #more of a validation on existing services, binaries,
#         #and setup. For now just keeping it simply, but maybe
#         #wiping /var/lib/jenkins, and creaint a symlink would
#         #be a strategy.
#         JENKINS_HOME=$_JENKINS_HOME
        
#     elif [[ "$_JENKINS_HOME" != "$JENKINS_HOME" ]] || [[ -d /var/lib/jenkins ]]; then
#         service stop jenkins
#         JENKINS_HOME=$_JENKINS_HOME
#         export JENKINS_HOME
#         #Might need to move the war file in /etc/default/jenkins as well
#         sed -i 's|/var/lib/\$NAME|'"${JENKINS_HOME}"'|g' /etc/default/jenkins
#         sed -i 's|/usr/share/java|'"${JENKINS_HOME}"'|g' /etc/default/jenkins
#         sed -i 's|/var/cache/\$NAME|'"${JENKINS_HOME}"'|g' /etc/default/jenkins
#         /var/cache/$NAME/war
#         #There is also a place where it point to the war file in /etc/default/jenkins
#         #might need to update that as well.
#         cp -prT /var/lib/jenkins/ $JENKINS_HOME
#         cp -prT ~/.jenkins $JENKINS_HOME
#         usermod -d $JENKINS_HOME jenkins
#         cp /usr/share/java/jenkins.war $JENKINS_HOME
#         chown jenkins:jenkins $JENKINS_HOME
#         cp /lib/systemd/system/jenkins.service /tmp/jenkins.service.bak
#         sed -i 's|/var/lib/\$NAME|'"${JENKINS_HOME}"'|g' /lib/systemd/system/jenkins.service
#         sed -i 's|/usr/share/java/|'"${JENKINS_HOME}"'|g' /lib/systemd/system/jenkins.service
#         #May need to run this when reattaching the volumejava -jar jenkins.war 01d04bcd15a44ab19ec09255ad3d7787
#         ##systemctl daemon-reload #systemd knows when a unit file has changed
        ###Environment="JENKINS_LOG=%L/jenkins/jenkins.log"
        #Environment="JENKINS_LISTEN_ADDRESS=127.0.0.1"
        # Set to true to enable logging to /var/log/jenkins/access_log.
        #Environment="JENKINS_ENABLE_ACCESS_LOG=false"
        
# fi
service jenkins start
# _uuid=$(blkid -o value -s UUID $_volume)
# if ! grep -q "$_uuid" "/etc/fstab"; then
#     cp /etc/fstab /etc/fstab.bak
#     echo "UUID=$_uuid  $JENKINS_HOME  xfs  defaults,nofail  0 2" | tee -a /etc/fstab
# fi
# make sure the fstab file was updated correctly
# if mount -a ; then 
#     #probably should ensure we are using imdv2
#     instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
#     echo "Updated fstab successfully, reboot with 'aws reboot-instances --instance-ids ${instanceId}'"
    
# else
#     echo "/etc/fstab not updated, need to do manually and reboot, see /etc/fstab.bad for issue"
#     cp /etc/fstab /etc/fstab.bad
#     mv /etc/fstab.bak /etc/fstab
# fi
# _setup_keystore=1
# if [[ $_setup_keystore -eq 0 ]]; then
#     export LDAPHOST='urldaphost.com'
#     export LDAPSSLPORT='3269'
#     export CERTFILENAME='/tmp/ldapcert.cer'
#     export keystore_pass="changeit"
#     echo "" | openssl s_client -connect $LDAPHOST:$LDAPSSLPORT 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERTFILENAME
#     keytool -import -trustcacerts -alias $LDAPHOST -file $CERTFILENAME -keystore $JAVA_HOME/lib/security/cacerts -storepass "$keystore_pass"
#     CUSTOM_TrustStore=$JENKINS_HOME/.cacerts/
#     mkdir -p $CUSTOM_TrustStore
#     cp $JAVA_HOME/jre/lib/security/cacerts $CUSTOM_TrustStore
#     $JAVA_HOME/bin/keytool -keystore $JENKINS_HOME/.cacerts/cacerts \
#     -import -alias $LDAPHOST -file $CERTFILENAME -storepass $keystore_pass
#     update-ca-certificates
# fi
#Setup reverse proxy with nginx for jenkins 
#https://www.jenkins.io/doc/book/system-administration/reverse-proxy-configuration-nginx/
# if [[ ! -d /etc/nginx ]]; then
#     apt install nginx -y
#     usermod -aG jenkins www-data
#     mkdir /var/log/nginx/jenkins
#     chgrp jenkins /var/log/nginx/jenkins
#     chmod -R 664 /var/log/nginx/jenkins
#     #openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt
# echo "
# server {
        
#         # SSL Configuration
#         listen 443 ssl default_server;        
#         listen [::]:443 ssl ipv6only=on;
#         ssl_certificate /etc/ssl/certs/nginx.crt;
#         ssl_certificate_key /etc/ssl/private/nginx.key;

#         access_log            /var/log/nginx/jenkins/access.log;
#         error_log             /var/log/nginx/jenkins/error.log;
#         #temp
#         server_name           jenknins.soinshane.com;
#         root                  /var/cache/jenkins/war/; 
#         ignore_invalid_headers off;
        
#         location ~ "'^/static/[0-9a-fA-F]{8}\/(.*)$'" {
#                 rewrite "'^/static/[0-9a-fA-F]{8}\/(.*)'" /\$1 last;
#         }
#         location /userContent {
#                 root /var/lib/jenkins/;
#                 if (!-f \$request_filename){
#                         rewrite (.*) /\$1 last;
#                         break;
#                 }
#                 sendfile on;
#         } 
#         location / {
#                 include /etc/nginx/proxy_params;
#                 proxy_pass          http://localhost:8080;
#                 proxy_read_timeout  90s;
#                 proxy_redirect      http://localhost:8080 https://jenkins.soinshane.com;
#         }
# }
# " > /etc/nginx/sites-available/jenkins.soinshane.com
#     ln -s /etc/nginx/sites-available/jenkins.soinshane.com /etc/nginx/sites-enabled/
#     systemctl stop jenkins
#     echo "Environment=\"JENKINS_LISTEN_ADDRESS=127.0.0.1\"" > /etc/systemd/system/jenkins.service.d/override.conf
#     ## Needed to fix reverse proxy error, but the escaping of $ in a script that echoes needs to be verified
# # echo "
# # proxy_set_header Host \$http_host;
# # proxy_set_header X-Real-IP \$remote_addr;
# # proxy_set_header X-Forwarded-Proto \$scheme;
# # " >> /etc/nginx/proxy_params
#     systemctl stop nginx
#     systemctl start nginx
#     systemctl start jenkins

# fi


#Anything that might need to be run on reboot could be
#put into the jenkins.sh script. There might be another
#process to get this into to ensure it is started up
#like systemd
