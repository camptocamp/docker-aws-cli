FROM docker

LABEL tools="docker-image, gitlab-aws, aws, helm, helm-charts, docker, gitlab, gitlab-ci, kubectl, s3, aws-iam-authenticator, ecr, bash, envsubst, alpine, curl, python3, pip3, git"
LABEL version="1.0.0"
LABEL description="An Alpine based docker image contains a good combination of commenly used tools\
 to build, package as docker image, login and push to AWS ECR, AWS authentication and all Kuberentes staff. \
 tools included: Docker, AWS-CLI, Kubectl, Helm, Curl, Python, Envsubst, Python, Pip, Git, Bash, AWS-IAM-Auth."
LABEL maintainer="eng.ahmed.srour@gmail.com"

ENV AWS_CLI_VERSION 1.16.214

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
    curl jq make bash ca-certificates groff less \
    && pip install awscli==$AWS_CLI_VERSION --upgrade --user \
    && apk --purge -v del py-pip \
    && rm -rf /var/cache/apk/*

ADD https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-Linux-x86_64 /usr/local/bin/envsubst
RUN chmod +x /usr/local/bin/envsubst


ADD https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
RUN chmod +x /usr/local/bin/aws-iam-authenticator

# Get the kubectl binary.
ADD https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl /usr/local/bin/kubectl

# Make the kubectl binary executable.
RUN chmod +x /usr/local/bin/kubectl

# Install GIT
RUN apk add --no-cache git

#ENV HELM_HOME=~/.helm
#RUN mkdir -p ~/.helm/plugins

#RUN git clone https://github.com/hypnoglow/helm-s3.git

# Install Helm
ADD https://storage.googleapis.com/kubernetes-helm/helm-v2.12.1-linux-amd64.tar.gz helm-linux-amd64.tar.gz
RUN tar -zxvf helm-linux-amd64.tar.gz
RUN mv linux-amd64/helm /usr/local/bin/helm

# Initialize Helm

RUN helm init --client-only

# Install Helm S3 Plugin
RUN helm plugin install https://github.com/hypnoglow/helm-s3.git

# Cleanup apt cache
RUN rm -rf /var/cache/apk/*

ENV LOG=file
#ENTRYPOINT ["docker --version"]
#CMD []

#CMD [jq -version]

#VOLUME /var/run/docker.sock:/var/run/docker.sock

WORKDIR /data
