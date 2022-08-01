* Search results incorrect links

* TEST:
  - re-install
  - Switch VERBOSE=true then false
  - When a new environment variable (e.g s3 bucket name) is added make sure update all files which contains that variable, particularly those read into the environment.

  - After updating variables ensure no VAR_ left in file ???
  sometimes this may not work as some variables e.g VAR_S3_BUCKET_NAME are updated
  when the name becomes available

  - TEst all links from all pages e.g using curl
------------------------------

* Add comments

* Improve search

* Use tags/categories https://github.com/gatsbyjs/gatsby/blob/master/docs/docs/adding-tags-and-categories-to-blog-posts.md

* READ this to properly manage terraform state:
https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa

* Production deploy only pages that have changed

* Ensure the below env variables does not reflect in properties
-------
HOSTNAME
PWD
HOME
SHLVL
PATH
OLDPWD
_
-------

* Use Node.js or java to do better maninipulation of `package.json` and
`gatsby-config.js`
