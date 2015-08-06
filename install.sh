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

check_packages() {
    for prg in $*; do
        dpkg -s $prg &>/dev/null || return $?
    done

    return 0
}

if ! check_packages openssh-server postfix gitlab-ce jenkins; then
    echo "Add jenkins repository."
    wget -qO- https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
    echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list

    echo "Install GitLab."
    curl -Lso /tmp/gitlab-ce.deb https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/wheezy/gitlab-ce_7.13.3-ce.1_amd64.deb/download
    dpkg -i /tmp/gitlab-ce.deb
    gitlab-ctl reconfigure

    echo "Update repository."
    apt-get update -qq

    echo "Install dependencies."
    DEBIAN_FRONTEND=nointeractive apt-get install -qq jenkins postfix openssh-server
else
    echo "Dependencies are already installed."
fi

echo "Installing jenkins plugins."
until wget -qO /dev/null http://localhost:8080/; do
    echo "Waiting..."
    sleep 5
done
wget -qO /tmp/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ install-plugin git gitlab-plugin docker-build-publish
rm /tmp/jenkins-cli.jar
