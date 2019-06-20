#FROM 			mcr.microsoft.com/dotnet/core/runtime:2.2.5-alpine3.8
#FROM ubuntu
FROM mcr.microsoft.com/dotnet/core/runtime:2.2

# ARG USER=octo
# ARG USER_UID=1000
# ARG USER_GID=500
ARG DOCKER_GID=233

MAINTAINER 		Gavin Jones <gjones@powerfarming.co.nz>
# https://download.docker.com/linux/static/stable/x86_64/
ENV 			DOCKER_VERSION 18.06.3-ce
# https://github.com/docker/compose/releases/
ENV 			DOCKER_COMPOSE_VERSION 1.24.0
# https://github.com/docker/machine/releases/
ENV 			DOCKER_MACHINE_VERSION 0.16.1
ENV	 			MACH_ARCH x86_64
ENV 			TERM xterm
# #To override if needed
# ARG 			TAG=dev
# ENV 			TAG ${TAG}
# # https://www.microsoft.com/net/learn/get-started/linuxubuntu
# ENV				DOTNET_PACKAGE dotnet-sdk-2.1

ARG 			PS_VERSION=6.2.0
ARG 			PS_PACKAGE=powershell-${PS_VERSION}-linux-x64.tar.gz
ARG 			PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}
ARG 			PS_INSTALL_VERSION=6

# libicu55?
RUN             apt-get update \
                && apt-get install -y openssl apt-transport-https sudo git nano wget curl iputils-ping dnsutils libunwind8 \
                && apt-get clean

RUN             groupadd -g 500 core && useradd -u 500 -g 500 -s /bin/bash core && useradd -u 1000 -g 500 -s /bin/bash octo && adduser core sudo

# Docker bin
RUN         	curl -L -o /tmp/docker-latest.tgz https://download.docker.com/linux/static/stable/${MACH_ARCH}/docker-${DOCKER_VERSION}.tgz && \
            	tar -xvzf /tmp/docker-latest.tgz && \
            	mv docker/* /usr/bin/ 

#Docker compose
RUN 			curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
				chmod +x /usr/local/bin/docker-compose

#Docker machine
RUN				curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
				chmod +x /usr/local/bin/docker-machine

#Minio tools
RUN				curl -L https://dl.minio.io/server/minio/release/linux-amd64/minio > /usr/local/bin/minio && \
				chmod +x /usr/local/bin/minio
RUN				curl -L https://dl.minio.io/client/mc/release/linux-amd64/mc > /usr/local/bin/mc && \
				chmod +x /usr/local/bin/mc

# #
# # Installing powershell-core
# #
# TEST
# curl -L ${PS_PACKAGE_URL} > /tmp/linux.tar.gz
ADD ${PS_PACKAGE_URL} /tmp/linux.tar.gz
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/$PS_INSTALL_VERSION
RUN mkdir -p ${PS_INSTALL_FOLDER}
RUN tar zxf /tmp/linux.tar.gz -C ${PS_INSTALL_FOLDER} \
	&& chmod +x ${PS_INSTALL_FOLDER}/pwsh \
	&& ln -s ${PS_INSTALL_FOLDER}/pwsh /usr/local/bin/pwsh  \
	&& ln -s ${PS_INSTALL_FOLDER}/pwsh /usr/local/bin/powershell

				
# Manually add groups and memberships as we're installing via bins
RUN             groupadd -g ${DOCKER_GID} docker && adduser core docker && adduser octo docker

# #Set PSGallery to trusted, and install PS module PSDepend by default
# #RUN				pwsh -c "Get-PSRepository; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
# #RUN				pwsh -c "Install-Module -Name PSDepend; Import-Module PSDepend"				

# RUN 			echo $TAG >> build_tag
