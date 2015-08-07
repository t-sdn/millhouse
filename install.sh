#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "Using sudo to continue."
    case $0 in
        bash)
            sudo $0 -s $*
            ;;
        *)
            sudo bash $0 $*
            ;;
    esac
    exit 0
fi

echo 'millhouse' > /etc/hostname
hostname -F /etc/hostname

echo "Add jenkins repository."
wget -qO- https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list

echo "Install GitLab."
curl -Lso /tmp/gitlab-ce.deb https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/wheezy/gitlab-ce_7.13.3-ce.1_amd64.deb/download
dpkg -i /tmp/gitlab-ce.deb

echo "Setting GitLab."
ip=$(curl ipv4.icanhazip.com)
sed -e "s#^external_url .*#external_url 'http://$ip:10080'#" -i /etc/gitlab/gitlab.rb
echo "gitlab_rails['gitlab_ssh_host'] = '$ip:10022'" >> /etc/gitlab/gitlab.rb

gitlab-ctl reconfigure

echo "Update repository."
apt-get update -qq

echo "Install dependencies."
DEBIAN_FRONTEND=nointeractive apt-get install -qq jenkins postfix openssh-server

echo "Setting jenkins."
sed -e 's/HTTP_PORT=.*/HTTP_PORT=8888/' -i /etc/default/jenkins
service jenkins restart
until wget -qO /dev/null http://localhost:8888/; do
    echo "Waiting..."
    sleep 5
done
wget -qO /tmp/jenkins-cli.jar http://localhost:8888/jnlpJars/jenkins-cli.jar
java -jar /tmp/jenkins-cli.jar -s http://localhost:8888/ install-plugin git gitlab-plugin docker-build-publish
rm /tmp/jenkins-cli.jar
