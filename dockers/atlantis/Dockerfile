FROM golang:1.13 as builder
RUN apt-get update \
  && apt-get install unzip

# Install terraform-bundle
RUN git clone \
  --depth 1 \
  --single-branch \
  --branch "v0.14" \
  https://github.com/hashicorp/terraform.git \
  $GOPATH/src/github.com/hashicorp/terraform
RUN cd $GOPATH/src/github.com/hashicorp/terraform \
  && go install ./tools/terraform-bundle

# Download plugins
COPY tf-bundle-config.hcl .
RUN terraform-bundle package -os=linux -arch=amd64 tf-bundle-config.hcl
RUN mkdir /go/tmp \
  && unzip /go/terraform_*-bundle*_linux_amd64.zip -d /go/tmp

FROM ghcr.io/runatlantis/atlantis:v0.19.3
ENV TF_IN_AUTOMATION="true"
ENV TF_CLI_ARGS_init="-plugin-dir=/home/atlantis/.atlantis/plugin-cache/plugins"

# Installin awscli
RUN apk add --update --no-cache curl py-pip aws-cli nodejs npm

# Copy plugins
COPY --chown=atlantis:atlantis --from=builder /go/tmp /home/atlantis/.atlantis/plugin-cache
RUN mv /home/atlantis/.atlantis/plugin-cache/terraform /usr/local/bin/terraform

# Shell script to generate atlantis.yaml file
COPY atlantis_config_gen.sh /home/atlantis/
COPY allowed_users.sh /home/atlantis/

CMD ["server"]

