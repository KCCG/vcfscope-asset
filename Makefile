SHELL=/bin/bash -e -x

# develop this Makefile in a cloud workstation, as sudo, since this Makefile will be executed as root:
# dx run kccg:/cloud_workstation -imax_session_length=120 --ssh --yes
# unset DX_WORKSPACE_ID
# dx cd $DX_PROJECT_CONTEXT_ID:
# sudo -s

all: bs

.PHONY: bs dependencies
bs:
	mv /etc/apt/apt.conf.d/99dnanexus /tmp
	echo -e "y\ny" | bash -c "$$(curl -L https://bintray.com/artifact/download/basespace/helper/install.sh)"
	bs -V
	mv /tmp/99dnanexus /etc/apt/apt.conf.d

dependencies:
	apt-get install --yes python-requests
