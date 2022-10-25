ARG OPERATING_SYSTEM_ARCHITECTURE_VERSION=latest


ARG OPERATING_SYSTEM_ARCHITECTURE_VERSION_GIT_BRANCH=master
ARG OPERATING_SYSTEM_ARCHITECTURE_VERSION_GIT_COMMIT=HEAD

FROM python:3.8

LABEL maintainer=ronaldsonbellande@gmail.com
LABEL version="1.0"
LABEL OPERATING_SYSTEM_architecture_github_branchtag=${OPERATING_SYSTEM_ARCHITECTURE_VERSION_GIT_BRANCH}
LABEL OPERATING_SYSTEM_architecture_github_commit=${OPERATING_SYSTEM_ARCHITECTURE_VERSION_GIT_COMMIT}

RUN apt-get update && apt-get install -y wget

# Kernel 
WORKDIR ./
RUN wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.0.3.tar.xz
RUN tar xvf linux-6.0.3.tar.xz

COPY system_requirements.txt .

# Install dependencies for system
RUN apt-get update && apt-get install -y --no-install-recommends <system_requirements.txt \
  && apt-get upgrade -y \
  && apt-get clean

USER root

# Initializaing Kernel 
RUN cd linux-6.0.3
RUN mkdir /kernel
RUN ls
RUN cp -v /kernel .config
# RUN cp -r /boot/ .config
RUN make menuconfig
RUN ls

RUN make
RUN make modules_install
RUN make install
RUN update-initramfs -c -k 6.0.3

# Grub Init
RUN update-grub

ENTRYPOINT ["sh","/root"]
# CMD ["/root"]
