#!/bin/bash

source ${g_scripts_dir}/functions-util.sh

gatsby_new_site() {

    local msg="Importing site from ${1}"

    echo ${msg}

    # Piping the result of echo is like piping of enter key press
    (echo | gatsby new ${SITE_DIR_NAME} ${1} ) \
    && echo "    SUCCESS: $msg" || (echo "    ERROR: $msg" && exit 1)
}

gatsby_clean() {
    if [ -d "${g_site_dir}" ]; then

        echo "Cleaning site"

        (cd ${g_site_dir} && gatsby clean)
    fi
}

gatsby_refresh() {

    # At the root of a Gatsby site, wipe out the cache (.cache folder) and public directories:
    gatsby_clean

    # Rather than the advised `rm -Rf node_modules && npm install` call yarn upgrade
    # @See https://github.com/gatsbyjs/gatsby/issues/18048
    #
    # @see https://classic.yarnpkg.com/en/docs/migrating-from-npm/
    #
#    (cd ${g_site_dir} && yarn upgrade)
}

# - Run a webserver on specified port on the local machine
# - Use nohup to ensure the web server keeps running even after script exits
# - & at the end so the web server runs in background; and the script can exit
# instead of waiting for the webserver
#
gatsby_develop() {

    echo "Publishing site to local web server at http://localhost:$APP_PORT"

    # @TODO try exec gatsby develop

    # Exited immediately. Site not reachable at localhost
#    nohup gatsby develop -H 0.0.0.0 -p ${APP_PORT} &

    # Blocks (i.e nothing after will execute till finishes)
    # Site up and running at localhost
#    nohup gatsby develop -H 0.0.0.0 -p ${APP_PORT}  WORKED .. but blocks.. nothing after executes
    (cd ${g_site_dir} && gatsby develop -H 0.0.0.0 -p ${APP_PORT}) # this blocks.. nothing after executes
}

gatsby_build() {
    local msg='Building site'
    echo $msg
    (cd ${g_site_dir} && yarn run build && echo "    SUCCESS: $msg" || echo "    ERROR: $msg")
}

# @see https://medium.com/@kyle.galbraith/how-to-host-a-website-on-s3-without-getting-lost-in-the-sea-e2b82aa6cd38
# If your website domain is www.my-awesome-site.com, then your bucket name must
# be www.my-awesome-site.com
aws_cli_deploy() {

    # Resulting URL format:  http://<AWS_S3_BUCKET_NAME>.s3.<AWS_REGION>.amazonaws.com/
#    (aws s3 website s3://${AWS_S3_BUCKET_NAME}/ --index-document index.html --error-document error.html) \
#        && echo "  SUCCESS configuring AWS s3 bucket ${AWS_S3_BUCKET_NAME} for website hosting" \
#        || echo "  ERROR configuring AWS s3 bucket ${AWS_S3_BUCKET_NAME} for website hosting" \

# If using this make sure you check the reference link above for policy JSON
#    aws s3api put-bucket-policy --bucket <AWS_S3_BUCKET_NAME> --policy file://policy.json

    # Map your domain name www.my-awesome-site.com, to your S3 website url
    # <AWS_S3_BUCKET_NAME>.s3.us-east-2.amazonaws.com. This mapping is often
    # referred to as a CNAME record inside of your Domain Name Servers (DNS) records.
    #
    # - Create a record for a host like www
    # - The record type must be CNAME (Canonical name)
    # - The value must be your S3 website url www.<AWS_S3_BUCKET_NAME>.s3.<AWS_REGION>.amazonaws.com

    ensure_aws_cli_configured

    # The command gatsby build will build your site locally, updating the public/*
    # files
    aws s3 cp ${g_site_dir}/public/ s3://${AWS_S3_BUCKET_NAME}/ --recursive
}

gatsby_plugin_s3_deploy() {

    echo 'Publishing site to amazon s3'
    if [ "$VERBOSE" = true ]; then
        (cd ${g_site_dir} && yarn run deploy -y)
    else
        (cd ${g_site_dir} && yarn run deploy --silent -y)
    fi
    echo 'Done publishing site to amazon s3'
}

gatsby_setup() {

    printloc

    gatsby telemetry --disable

    local gatsby_node_module_dir="${g_site_dir}/node_modules/gatsby-cli"
    if [ -d "$gatsby_node_module_dir" ] && [ "$(ls -A ${gatsby_node_module_dir})" ]; then
        echo ""
    else
        echo "  WARNING: Node modules not found."
        exit 1
    fi

    if [ "$PROFILE" == 'dev' ]; then
        gatsby_develop
    else
        gatsby_build
    fi
}

gatsby_deploy() {

    aws_cli_deploy
}

retry_gatsby_setup() {
    gatsby_refresh
    echo 'Retrying setup of site'
    gatsby_setup
}

retry_gatsby_deploy() {
    gatsby_refresh
    echo 'Retrying deploy of site'
    gatsby_deploy
}
