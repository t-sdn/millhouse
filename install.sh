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
        hash $prg 2>/dev/null || return 1
    done

    return 0
}

if ! check_packages docker; then
    echo "Update repository."
    apt-get update -qq

    echo "Install docker."
    apt-get install -qq docker.io
else
    echo "Dependencies are already installed."
fi

echo "Add user to docker group"
usermod -aG docker $SUDO_USER

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

cat > /etc/systemd/system/jenkins-docker.service << EOF
[Unit]
Description=Jenkins ci in docker.
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker pull jenkins
ExecStartPre=-/usr/bin/docker rm jenkins-ci
ExecStart=/usr/bin/docker run --rm \
          --name jenkins-ci \
          --volume /srv/jenkins:/var/jenkins_home \
          --publish 8080:8080 \
          jenkins
ExecStop=/usr/bin/docker stop jenkins-ci

[Install]
WantedBy=local.target
EOF

cat > /etc/systemd/system/docker-registry.service << EOF
[Unit]
Description=Private docker registry.
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker pull registry
ExecStartPre=-/usr/bin/docker rm docker-registry
ExecStart=/usr/bin/docker run --rm \
          --name docker-registry \
          --volume /srv/registry:/tmp/registry \
          --publish 192.168.0.10:5000:5000 \
          registry
ExecStop=/usr/bin/docker stop docker-registry

[Install]
WantedBy=local.target
EOF

echo "Fix jenkins permission"
mkdir -p /srv/jenkins
chown -R 1000:1000 /srv/jenkins

systemctl enable gitlab-docker jenkins-docker docker-registry
systemctl start gitlab-docker jenkins-docker docker-registry
