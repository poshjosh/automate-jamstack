FROM pandoc/core

LABEL maintainer="https://github.com/poshjosh <posh.bc@gmail.com>"

ARG APP_PORT=8000
ENV APP_PORT=${APP_PORT}

EXPOSE ${APP_PORT}

ARG TERRAFORM_VERSION="0.12.23"

RUN apk update && apk upgrade \
    && apk add util-linux \
    && apk add bash git openssh npm yarn \
    && bash --version && git --version && ssh -V && npm -v && node -v && yarn -v \
    && apk add \
     	  ca-certificates \
    	  groff \
    	  less \
        curl \
    	  python \
    	  py-pip \
        unzip \
    && rm -rf /var/cache/apk/* \
    && pip install awscli \
    && aws --version \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip '*.zip' -d /usr/local/bin \
    && rm *.zip

#ARG SITE_DIR_NAME=default-site

#ENV SITE_DIR_NAME=${SITE_DIR_NAME}

# Set the working directory to override any set by base image
# This will create the directory if it doesn't exist
WORKDIR /

RUN yarn global add fs-extra gatsby-cli

# Copy the content into the sites directory. The previously added "node_modules"
# directory will not be overridden.
COPY ./sites/ ./sites/

COPY ./docker-entrypoint.sh .

RUN chmod +x ./docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
