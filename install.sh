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

echo "Install GitLab."
curl -Lso /tmp/gitlab-ce.deb https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/wheezy/gitlab-ce_7.13.3-ce.1_amd64.deb/download
dpkg -i /tmp/gitlab-ce.deb

echo "Setting GitLab."
ip=$(curl ipv4.icanhazip.com)
sed -e "s#^external_url .*#external_url 'http://$ip:10080'#" -i /etc/gitlab/gitlab.rb
echo "gitlab_rails['gitlab_ssh_host'] = '$ip:10022'" >> /etc/gitlab/gitlab.rb
echo "ci_external_url 'http://$ip:18181'" >> /etc/gitlab/gitlab.rb

gitlab-ctl reconfigure

echo "Update repository."
apt-get update -qq

echo "Install dependencies."
DEBIAN_FRONTEND=nointeractive apt-get install -qq postfix openssh-server nis rpcbind

echo "Setting NIS."
sed -e 's/^NISSERVER=.*/NISSERVER=master/' -e 's/^NISCLIENT=.*/NISCLIENT=false/' -i /etc/default/nis

sudo service rpcbind restart
sudo service nis restart
/usr/lib/yp/ypinit -m < /dev/null
