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

get_private_ip() {
    ips=$(ifconfig | awk '/inet addr/{print substr($2,6)}')
    for ip in $ips; do
        if [ $ip == '10.*.*.*' ]; then
            echo $ip
            return 0
        elif [ $ip == '192.168.*.*' ]; then
            echo $ip
            return 0
        elif [ $ip == '172.*.*.*' ]; then
            second_field=$(cut -d. -f2 <<< $ip)
            if [ $second_field -ge 16 -a $second_field -le 31 ]; then
                echo $ip
                return 0
            fi
        fi
    done

    return 1
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

bind_ip=$(get_private_ip || echo '0.0.0.0')

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
          --publish $bind_ip:5000:5000 \
          registry
ExecStop=/usr/bin/docker stop docker-registry

[Install]
WantedBy=local.target
EOF

systemctl enable jenkins gitlab-docker docker-registry
systemctl start jenkins gitlab-docker docker-registry
