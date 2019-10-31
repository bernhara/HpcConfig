FROM nvidia/cuda:10.1-cudnn7-runtime-centos7
ARG PYTHON_VERSION=36

RUN yum install -y epel-release && \
    yum clean all

RUN yum install -y python$PYTHON_VERSION python$PYTHON_VERSION-pip && \
    yum clean all

RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install pipenv

RUN python3 -m pip install jupyter

#!!RUN groupadd -r -g 1002 d_yfgi6212
#!!RUN useradd -r -u 1001 --no-log-init -g d_yfgi6212 d_yfgi6212
#!!
#!!WORKDIR /image_workspace
#!!
#!!
#!!USER d_yfgi6212
