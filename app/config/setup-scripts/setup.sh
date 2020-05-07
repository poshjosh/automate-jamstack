#!/bin/bash

# If variable doesn't start with forward slash prefix it with forward slash
[[ ${SITE_PAGES_DIR} == /* ]] || SITE_PAGES_DIR="/${SITE_PAGES_DIR}"
g_config_dir="./config"
g_scripts_dir="${g_config_dir}/setup-scripts"
g_data_dir="${g_config_dir}/site-data"
g_pandoc_template_file="$g_data_dir/pandoc-template.markdown"
g_site_data_dir="${g_data_dir}/${SITE_DIR_NAME}"
g_terraform_dir="${g_config_dir}/terraform"
g_site_terraform_dir="${g_site_data_dir}/terraform"
g_sites_dir="./sites"
g_site_dir="${g_sites_dir}/${SITE_DIR_NAME}"

source ${g_scripts_dir}/functions-find.sh
source ${g_scripts_dir}/functions-gatsby.sh
source ${g_scripts_dir}/functions-pages.sh
source ${g_scripts_dir}/functions-util.sh
source ${g_scripts_dir}/functions-yarn.sh

debug "$(date) - [ Beginning setup ] - Build no 298"
if [ "$VERBOSE" = true ]; then
    env
    debug "============================================"
fi

printloc

site_install_filename='/app-installed.state'
site_install_file="${g_site_data_dir}${site_install_filename}"
if [ -f "$site_install_file" ]; then
    firstrun=false
else
    firstrun=true
    write_to_file 'installed' ${g_site_data_dir} $site_install_filename
fi
debug "First run: $firstrun"

ensure_aws_cli_configured() {
    local aws_config_file="${HOME}/.aws/config"
    local aws_cred_file="${HOME}/.aws/credentials"
    if [ -f "$aws_config_file" ] && [ -f "$aws_cred_file" ]; then
        debug "AWS CLI already configured"
    else
        chmod +x ${g_scripts_dir}/configure-aws-cli.sh
        /bin/bash ${g_scripts_dir}/configure-aws-cli.sh
    fi
}

ensure_aws_cli_configured

is_site_newly_imported=false

# Import the site from source
#
import_site() {

    if [ -z ${1+x} ] || [ "$1" == '' ]; then
        debug "A source for the site was not specified will use contents of directory: ${g_site_dir}"
    else

        remove_dir "${g_site_dir}"

        local tmp_dir="${g_sites_dir}/temp"

        remove_dir "$tmp_dir"

        import ${1} ${tmp_dir}

        local pkg_json="${tmp_dir}/package.json"

        if [ -f "$pkg_json" ]; then
            find_and_replace_env_variables_in_file ${pkg_json}
        else
             debug "File not found: $pkg_json"
        fi

        local site_source=$tmp_dir
        if [[ ${tmp_dir} == /* ]]; then
            site_source="..$tmp_dir"
        elif [[ ${tmp_dir} == ./* ]]; then
            site_source=".$tmp_dir"
        else
            site_source=$tmp_dir
        fi

        (cd ${g_sites_dir} && (gatsby_new_site "${site_source}" && is_site_newly_imported=true))

        remove_dir ${tmp_dir}
    fi
}

is_site_already_imported=false
check_site_imported() {
    local site_node_modules_dir="${g_site_dir}/node_modules"
    if [ -d "$site_node_modules_dir" ]; then
        is_site_already_imported=true
    else
        is_site_already_imported=false;
    fi
    debug "Site is imported: $is_site_already_imported"
}

check_site_imported

if [ "${is_site_already_imported}" = false ] || [ "$REFRESH_SITE" = true ]; then

    remove_dir "${g_site_dir}"

    import_site ${SITE_SOURCE}
fi


if [ "$REFRESH_SITE_CACHE" = true ] && [ "$is_site_newly_imported" = false ]; then

    site_cache_dir="${g_site_dir}/.cache"

    remove_dir "$site_cache_dir"
fi

is_site_pages_already_imported=false
site_pages_loc="${g_site_dir}${SITE_PAGES_DIR}"
check_site_pages_imported() {
    if [ -d "$site_pages_loc" ] && [ "$(ls -A $site_pages_loc)" ]; then
        is_site_pages_already_imported=true
    else
        is_site_pages_already_imported=false;
    fi
    debug "Site pages are imported: $is_site_pages_already_imported"
}

import_site_pages() {

    check_site_pages_imported

    if [ "${is_site_pages_already_imported}" = false ] || [ "$REFRESH_SITE_PAGES" = true ]; then

# After applying this, we still found some files with .deleted extension
#        provide_empty_dir $site_pages_loc
        remove_dir $site_pages_loc

        make_dir $site_pages_loc

        import ${SITE_PAGES_SOURCE} ${site_pages_loc}
    fi
}

if [ "$is_site_newly_imported" = false ]; then
    import_site_pages
fi

echo 'Updating configuration'

find_and_replace_variables() {

    local file="${g_scripts_dir}/list_of_files_containing_variables.txt"

    debug "Will find and replace all variables in files listed in $file"
    debug "    BEGIN FIND AND REPLACE"
    debug "======================================================================"
    debug ""
    debug "Function to apply = custom_find_and_replace_variables_in_file"
    act_on_files_listed_in_file $file custom_find_and_replace_variables_in_file

    debug ""
    debug "Function to apply = find_and_replace_env_variables_in_file"
    act_on_files_listed_in_file $file find_and_replace_env_variables_in_file

    debug "    END FIND AND REPLACE"
    debug "======================================================================"
}

find_and_replace_variables

# Init terraform and use it to automate the creation of amazon s3 bucket

terraform_ok=true
site_terraform_filename='/bucket-created.state'
site_terraform_file="${g_site_terraform_dir}${site_terraform_filename}"
site_tfstate_file="${g_site_terraform_dir}/terraform.tfstate"
if [ -f "${site_terraform_file}" ] || [ -f "$site_tfstate_file" ]; then
    virgin=false
else
    virgin=true;
fi

update_terraform_cfgs() {

    debug "Updating terraform configuration"

    make_dir ${g_site_terraform_dir}

    if [ -z ${AWS_S3_BUCKET_NAME+x} ] || [ "$AWS_S3_BUCKET_NAME" == '' ]; then

        debug "An s3 bucket name was not specified. Will generate one"

        local epoch_time=$(date '+%s')
        local raw_name="${AWS_S3_BUCKET_NAME_PREFIX}-${SITE_DIR_NAME}-${epoch_time}"
        local polished_name=$(echo $raw_name | tr '[:upper:]' '[:lower:]')

        # Export this to our list of environtment variables
        export "AWS_S3_BUCKET_NAME=${polished_name}" \
            && bucketname_set=true || bucketname_set=false

        if [ "$bucketname_set" = true ]; then

            debug "  SUCCESS: set AWS_S3_BUCKET_NAME = $AWS_S3_BUCKET_NAME"

            props_file="${g_site_dir}.env"

            debug "Updating $props_file with environment AWS_S3_BUCKET_NAME"

            # Update our persistent store with the updated list of environment
            # variables which should now contain AWS_S3_BUCKET_NAME
            env > $props_file && "  SUCCESS: Saved bucket name" || "  ERROR: Bucket name not saved"

        else
            debug "  ERROR: Not set- AWS_S3_BUCKET_NAME = $AWS_S3_BUCKET_NAME"
        fi
    else
        debug "Existing AWS_S3_BUCKET_NAME = $AWS_S3_BUCKET_NAME"
    fi

    if [ -z ${AWS_S3_BUCKET_NAME+x} ] || [ "$AWS_S3_BUCKET_NAME" == '' ]; then
        "Value not set for AWS_S3_BUCKET_NAME. S3 bucket will not be created"
        terraform_ok=false
    fi

    if [ "$terraform_ok" = true ]; then

        cp -R "${g_terraform_dir}/." ${g_site_terraform_dir}

        find_and_replace_variables

        success "Updated terraform configuration"
    else
         error "Not updated - terraform configuration"
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

    if [ "$virgin" = true ] || [ "$AWS_S3_UPDATE_BUCKET" = true ]; then

        local msginit='Intializing s3 bucket provisioner'
        echo $msginit
        terraform_init ${g_site_terraform_dir} \
            && success "$msginit" || error "$msginit"

        local msgapply='Creating/Updating s3 bucket'
        echo $msgapply
        local applied=false;
        terraform_apply ${g_site_terraform_dir} && applied=true || applied=false
        if [ "$applied" = true ]; then
            success "$msgapply"
            write_to_file 's3-bucket-created' ${g_site_terraform_dir} ${site_terraform_filename}
        else
            error "$msgapply"
        fi
    else
        debug "Terraform already initialized for ${g_site_terraform_dir}"
    fi
}

if [ "$PROFILE" == 'prod' ]; then

    update_terraform_cfgs

    if [ "$terraform_ok" = true ]; then create_or_update_s3_bucket; fi

    printloc
fi

update_pages() {

    local pagesdir=${g_site_dir}${SITE_PAGES_DIR}
    local backupdir="${g_site_dir}/backups${SITE_PAGES_DIR}"

    if [ -d "${pagesdir}" ]; then

        add_frontmatter_to_markdown ${pagesdir}
        update_markdown_links ${pagesdir} ${backupdir}

        if [ "$PAGE_ADD_TABLE_OF_CONTENT" = true ]; then
            add_tableofcontents_to_markdown ${pagesdir} $g_pandoc_template_file
        fi
    fi
}

# Update pages
#
update_pages

gatsby_setup

if [ "$PROFILE" == 'prod' ]; then
    gatsby_deploy
fi

echo 'Completed setup'
