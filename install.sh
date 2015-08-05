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

if ! check_packages docker.io jenkins; then
    echo "Add jenkins repository."
    wget -qO- https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
    echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list

    echo "Update repository."
    apt-get update -qq

    echo "Install dependencies."
    apt-get install -qq docker.io jenkins

    echo "Add user to docker group"
    usermod -aG docker $SUDO_USER
else
    echo "Dependencies are already installed."
fi

echo "Setting systemd config."
cat > /etc/systemd/system/gitlab-docker.service << EOF
[Unit]
Description=Gitlab in docker.
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker pull gitlab/gitlab-ce
ExecStartPre=-/usr/bin/docker rm gitlab-ce
ExecStart=/usr/bin/docker run --rm \
          --name gitlab-ce \
          --volume /srv/gitlab/config:/etc/gitlab \
          --volume /srv/gitlab/logs:/var/log/gitlab \
          --volume /srv/gitlab/data:/var/opt/gitlab \
          --publish 80:80 --publish 2222:22 \
          gitlab/gitlab-ce
ExecStop=/usr/bin/docker stop gitlab-ce

[Install]
WantedBy=local.target
EOF

systemctl enable jenkins gitlab-docker
systemctl start jenkins gitlab-docker

echo "Installing jenkins plugins."
until wget -qO /dev/null http://localhost:8080/; do
    echo "Waiting..."
    sleep 5
done
wget -qO /tmp/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ install-plugin git gitlab-plugin docker-build-publish
rm /tmp/jenkins-cli.jar
