#!/bin/bash

source ./setup-scripts/functions-find.sh
source ./setup-scripts/functions-page.sh
source ./setup-scripts/functions-util.sh
source ./setup-scripts/functions.sh

echo "$(date) - [ Beginning setup ] - Build no 289"
if [ "$VERBOSE" = true ]; then
    env
    echo "============================================"
fi

printloc

SITE_DIR="./${SITE_DIR_NAME}"

# If variable doesn't start with forward slash prefix it with forward slash
[[ ${SITE_PAGES_DIR} == /* ]] || SITE_PAGES_DIR="/${SITE_PAGES_DIR}"

site_install_filename='/app-installed.state'
site_install_file_dir="./site-data/${SITE_DIR_NAME}"
site_install_file="${site_install_file_dir}${site_install_filename}"
if [ -f "$site_install_file" ]; then
    firstrun=false
else
    firstrun=true
    write_to_file 'installed' $site_install_file_dir $site_install_filename
fi
echo "First run: $firstrun"

aws_config_file="${HOME}/.aws/config"
aws_cred_file="${HOME}/.aws/credentials"

ensure_aws_cli_configured() {

    if [ -f "$aws_config_file" ] && [ -f "$aws_cred_file" ]; then
        echo "AWS CLI already configured"
    else
        chmod +x ./setup-scripts/configure-aws-cli.sh
        /bin/bash ./setup-scripts/configure-aws-cli.sh
    fi
}

ensure_aws_cli_configured

# Import the site from source
#
import_site() {

    if [ -z ${SITE_SOURCE+x} ] || [ "$SITE_SOURCE" == '' ]; then
        echo "A source for the site was not specified will use contents of directory: ${SITE_DIR}"
    else

        msg="Importing site ${SITE_DIR_NAME} from source ${SITE_SOURCE}"

        echo ${msg}

        # Piping the result of echo is like piping of enter key press
        (echo | gatsby new ${SITE_DIR_NAME} ${SITE_SOURCE}) \
        && echo "    SUCCESS: $msg" || echo "    ERROR: $msg"
    fi
}

is_site_imported='n'
check_site_imported() {
    local site_node_modules_dir="${SITE_DIR}/node_modules"
    if [ -d "$site_node_modules_dir" ]; then
        is_site_imported='y'
    else
        is_site_imported='n';
    fi
    echo "Is site imported: $is_site_imported"
    echo $is_site_imported
}

check_site_imported

if [ "${is_site_imported}" = 'n' ] || [ "$REFRESH" = true ]; then

    if [ -d "./$SITE_DIR_NAME" ]; then rm -Rf "./$SITE_DIR_NAME"; fi

    import_site
fi

install_plugin() {

    yarn_add_plugin $1 $2
}

install_plugin_if_not_installed() {
    local plugin_install_dir="${1}/node_modules/${2}"
    if [ -d "$plugin_install_dir" ] && [ "$(ls -A $plugin_install_dir)" ]; then
        echo "Plugin already installed: ${2}"
    else
        (cd ${1} && install_plugin ${2} ${3}) # the enclosing bracket keeps the change directory within context
    fi
}

echo 'Updating configuration'

# Update package.json, gatsby-config.js and terraform configuration
#
################################################################################

site_terraform_dir="./site-terraform/${SITE_DIR_NAME}"

update_cfgs() {

    echo "Updating configuration in $SITE_DIR_NAME"

    mkdir -p "./${SITE_DIR_NAME}/src/templates"
    mkdir -p "./${SITE_DIR_NAME}/backups/src/templates"

    backup_and_replace_files "./site-root/${SITE_DIR_NAME}" "./${SITE_DIR_NAME}"

    # We seperate these 2 from the rest to fulfill the following requirement:
    #
    # SITE_AUTHOR_SUMMARY must come before SITE_AUTHOR to avoid partial
    # replacement of SITE_AUTHOR_SUMMARY
    #
    custom_find_and_replace VAR_SITE_AUTHOR_SUMMARY $SITE_AUTHOR_SUMMARY
    custom_find_and_replace VAR_SITE_AUTHOR $SITE_AUTHOR

    custom_find_and_replace AWS_S3_BUCKET_NAME_PREFIX $AWS_S3_BUCKET_NAME_PREFIX
    custom_find_and_replace AWS_S3_BUCKET_NAME $AWS_S3_BUCKET_NAME

    local temp_env_file=$(mktemp)

    # Output environment variables to the temp file
    env > $temp_env_file

    while read line; do

        # Remove leading and trailing space chars, as well as windows line endings (\r)
        local kv_pair=$(echo $line | sed -e 's/^\s*//g' -e 's/*\s$//g' -e 's/\r$//')

        # Using delimiter `=`, split this, collect first part
        local pair_key=$(echo $kv_pair | cut -d= -f 1)

        # Using delimiter `=`, split this, collect second part
        local pair_val=$(echo $kv_pair | cut -d= -f 2)

        custom_find_and_replace "VAR_$pair_key" $pair_val

        if [ -z ${pair_val+x} ] || [ "$pair_val" == '' ]; then
            echo "Value not set for VAR_$pair_key"
        else
            find_and_replace_text_in_dir_mirror "terraform" ${site_terraform_dir} "VAR_$pair_key" $pair_val
        fi
    done < $temp_env_file

    rm -f $temp_env_file
}

update_cfgs

# Init terraform and use it to automate the creation of amazon s3 bucket

terraform_ok=true
site_terraform_filename='/bucket-created.state'
site_terraform_file="${site_terraform_dir}${site_terraform_filename}"
site_tfstate_file="${site_terraform_dir}/terraform.tfstate"
if [ -f "${site_terraform_file}" ] || [ -f "$site_tfstate_file" ]; then
    virgin=false
else
    virgin=true;
fi

update_terraform_cfgs() {

    echo "Updating terraform configuration"

    mkdir -p ${site_terraform_dir}

    if [ -z ${AWS_S3_BUCKET_NAME+x} ] || [ "$AWS_S3_BUCKET_NAME" == '' ]; then

        echo "An s3 bucket name was not specified. Will generate one"

        local epoch_time=$(date '+%s')
        local raw_name="${AWS_S3_BUCKET_NAME_PREFIX}-${SITE_DIR_NAME}-${epoch_time}"
        local polished_name=$(echo $raw_name | tr '[:upper:]' '[:lower:]')

        # Export this to our list of environtment variables
        export "AWS_S3_BUCKET_NAME=${polished_name}" \
            && bucketname_set=true || bucketname_set=false

        if [ "$bucketname_set" = true ]; then

            echo "  SUCCESS: set AWS_S3_BUCKET_NAME = $AWS_S3_BUCKET_NAME"

            props_file="./${SITE_DIR_NAME}.env"

            echo "Updating $props_file with environment AWS_S3_BUCKET_NAME"

            # Update our persistent store with the updated list of environment
            # variables which should now contain AWS_S3_BUCKET_NAME
            env > $props_file && "  SUCCESS: Saved bucket name" || "  ERROR: Bucket name not saved"

        else
            echo "  ERROR: Not set- AWS_S3_BUCKET_NAME = $AWS_S3_BUCKET_NAME"
        fi
    else
        echo "Existing AWS_S3_BUCKET_NAME = $AWS_S3_BUCKET_NAME"
    fi

    if [ -z ${AWS_S3_BUCKET_NAME+x} ] || [ "$AWS_S3_BUCKET_NAME" == '' ]; then
        "Value not set for AWS_S3_BUCKET_NAME. S3 bucket will not be created"
        terraform_ok=false
    fi

    if [ "$terraform_ok" = true ]; then

        (backup_and_replace_files "terraform" ${site_terraform_dir}) \
            && terraform_ok=true || terraform_ok=false

        update_cfgs

        echo "  SUCCESS: Updated terraform configuration"
    else
         echo "  ERROR: Not updated - terraform configuration"
    fi
}

terraform_init() {
    (cd ${1} && terraform init)
}

terraform_apply() {
    (cd ${1} && (echo 'yes' | terraform apply))
}

create_or_update_s3_bucket() {

    printloc

    if [ "$virgin" = true ] || [ "$AWS_UPDATE_S3_BUCKET" = true ]; then

        local msginit='Intializing s3 bucket provisioner'
        echo $msginit
        terraform_init ${site_terraform_dir} \
            && echo "    SUCCESS: $msginit" || echo "    ERROR: $msginit"

        local msgapply='Creating/Updating s3 bucket'
        echo $msgapply
        local applied=false;
        terraform_apply ${site_terraform_dir} && applied=true || applied=false
        if [ "$applied" = true ]; then
            echo "    SUCCESS: $msgapply"
            write_to_file 's3-bucket-created' ${site_terraform_dir} ${site_terraform_filename}
        else
            echo "    ERROR: $msgapply"
        fi
    else
        echo "Terraform already initialized for ${site_terraform_dir}"
    fi
}

if [ "$PROFILE" == 'prod' ]; then

    update_terraform_cfgs

    if [ "$terraform_ok" = true ]; then create_or_update_s3_bucket; fi

    printloc
fi

################################################################################

update_pages() {

    local pagesdir=${SITE_DIR}${SITE_PAGES_DIR}
    local backupdir="${SITE_DIR}/backups${SITE_PAGES_DIR}"

    if [ -d "${pagesdir}" ]; then
        add_frontmatter_to_markdown ${pagesdir}
        update_markdown_links ${pagesdir} ${backupdir}
    fi
}

# Update pages
#
update_pages

gatsby_setup

if [ "$PROFILE" == 'prod' ]; then
    gatsby_deploy
fi

# @see https://webpack.js.org/guides/getting-started/
#
setup_node() {

    yarn init -y

    install_plugin_if_not_installed '.' fs-extra false
    install_plugin_if_not_installed '.' lodash false
    install_plugin_if_not_installed '.' mocha true
    install_plugin_if_not_installed '.' webpack true
    install_plugin_if_not_installed '.' webpack-cli true
}

# if [ "$firstrun" = true ]; then
#     (cd ./site-setup && (setup_node && echo "node setup sucessful" || echo "node setup failed"))
# fi

# if [ "${PROFILE}" == 'dev' ] || [ "$firstrun" = true ]; then
    # (cd ./site-setup && yarn run build)
# fi

# app_dir='./site-setup/dist-dev'
# if [ "${PROFILE}" == 'prod' ]; then app_dir='./site-setup/dist-prod'; fi

# (cd ${app_dir} \
#    && (node app.js && echo "Done setting up app via nodejs" || echo "Command failed: node app.js") \
#    || echo "Failed to access app directory: ./site-setup/dist-prod")

echo 'Completed setup'
