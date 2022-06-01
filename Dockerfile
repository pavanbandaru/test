FROM centos:8

LABEL Maintainer="pavan"

WORKDIR /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum update -y

RUN yum install -y wget tar gzip libicu dnf
RUN dnf install -y java maven git

RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

WORKDIR  /
RUN wget https://github.com/CycloneDX/cyclonedx-cli/releases/download/v0.24.0/cyclonedx-linux-x64
RUN chmod a+x cyclonedx-linux-x64 && mv cyclonedx-linux-x64 cyclonedx-cli
WORKDIR /usr/bin
RUN ln -s /cyclonedx-cli cyclonedx-cli

RUN yum install epel-release -y
RUN dnf module install nodejs:12 -y

RUN yum install python39 -y
RUN yum install python3-pip -y

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3.9 get-pip.py
RUN pip3 install cyclonedx-python-lib
RUN pip3 install cyclonedx-bom
RUN dnf install -y dotnet-sdk-5.0

RUN dotnet tool install --global CycloneDX --version 2.3.0

RUN echo 'export PATH=$PATH:/root/.dotnet/tools' > ~/.bash_profile
WORKDIR /usr/bin
RUN ln -s /root/.dotnet/tools/dotnet-CycloneDX cyclonedx

VOLUME ["/sbom-java","/sbom-dotnet","/sbom-python"]
