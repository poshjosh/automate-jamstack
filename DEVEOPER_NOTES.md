### Developer Notes ###

Some errors may be caused by:

- Unstable internet connection.

- Restrictions from antivirus or firewall applications.

- Using windows line endings `CRLF` rather than `LF` on files used in docker
or other linux based systems.

The first time you run gatsby new for a directory/folder you will be asked:

```
✔ Which package manager would you like to use ? ›
```

To automate the response, enter the following command:

```
$ echo | gatsby new hello-world https://github.com/gatsbyjs/gatsby-starter-hello-world
```

There are two options ```yarn``` and ```npm```. The default (i.e ```yarn```) is
selected by the above command because echo implicitly generates a new line (i.e enter) by default.

Other options: ```echo -ne '\n' |``` , ```echo '\n' |``` , ```echo '\r' |```

Change to the directory created by the ```gatsby new``` command above:
```
cd hello-world
```

Stand up a development server accessible at ```http://localhost```

```
gatsby develop -H 0.0.0.0 -p 8000
```

### Convert .md to .html files with pandoc ###

- The ```pandoc/core``` image contains pandoc and pandoc-citeproc.

- The ```pandoc/latex``` image also contains the minimal LaTeX installation needed to produce PDFs using pandoc.

We build out pandoc image using the ```pandoc/core``` as base image.

Change to the ```pandoc``` directory/folder, there is a ```Dockerfile``` there.

```
cd pandoc
```

Run the following command to build an image from the ```Dockerfile```:

```
docker build -t poshjosh/pandoc .
```

The working directory for the built image is ```<CURRENT_DIRECTORY>/site```
(_corresponds to the gatsby image working directory_)
This means whichever directory you run the image from should have a ```site```
directory with content which is to be changed from ```.md``` to ```.html```

To achieve the above, change back to the parent directory of the ```pandoc```
before running the next command.
```
cd ..
```

This command will run the image, and find all ```.md``` files in the specified
directory which is relative to the working directory (i.e ```<CURRENT_DIRECTORY>/site```),
and for each such file found, generate a `.html` file and save it in the same directory.

```
docker run --name poshjosh-pandoc --rm -v "%cd%/site":/site --user 0 poshjosh/pandoc find ./hello-world/public -iname "*.md" -type f -exec sh -c "pandoc -s --toc -c styles.css -B header.html -A footer.html ${0} -o ./$(basename ${0%.md}.html)" {} ;
```

Notes:

- For linux replace ``` %cd% ``` with ``` `pwd` ```

- When entering the above command as a text literal, then escape the last semi-colon
`;` as such `\;`

Example usage to convert a single file from ```.md``` to ```.html```:

```
docker run --name poshjosh-pandoc --rm -v "%cd%/site":/site --user 0 poshjosh/pandoc pandoc -s --toc -c styles.css -B header.html -A footer.html ./hello-world/README.md -o ./hello-world/README.html
```

docker run --name poshjosh-jamstack -it --rm -v "%cd%/site":/site -u 0 -p 8000:8000 poshjosh/jamstack

### Notes: ###

- If you want to configure git, run

```
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
```

to set your account's default identity.
Omit --global to set the identity only in this repository.

- The image at [Gatsbyjs github page for gatsby-docker](https://github.com/gatsbyjs/gatsby-docker) did not work for me. When I tried to build the image from the docker file recommended, I got the error:

### References ###

Gatsby
- [Gatsbyjs - Add global CSS](https://www.gatsbyjs.org/docs/global-css/)

- [Gatsbyjs - Deploying to Amazon S3](https://www.gatsbyjs.org/docs/deploying-to-s3-cloudfront/)

- [Gatsbyjs - Quck start](https://www.gatsbyjs.org/docs/quick-start/)

- [Gatsbyjs - Tutorial](https://www.gatsbyjs.org/tutorial/part-zero/)

Terraform

- [Terraform - AWS S3 Bucket](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)

- [Terraform - Module S3 Bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket)

- [Cloudposse - Terraform Module for AWS S3 Website](https://github.com/cloudposse/terraform-aws-s3-website)

- [](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/1.6.0)

AWS S3

- [AWS - Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)

- [AWS - Guide to Static Web Hosting](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/static-website-hosting.html)

- [AWS - Getting Started with Static Websites](https://aws.amazon.com/getting-started/hands-on/host-static-website/)

- [AWS Policy Generator](https://awspolicygen.s3.amazonaws.com/policygen.html)

- [AWS - Secure S3 Resources](https://aws.amazon.com/premiumsupport/knowledge-center/secure-s3-resources/)

Pandoc

- [Why use Pandoc](http://wusun.name/blog/2018-07-16-markdown-publishing/)

- [Pandoc - Installation](https://pandoc.org/installing.html)

- [Pandoc - Demos](https://pandoc.org/demos.html)

- [Pandoc - Manual](https://pandoc.org/MANUAL.html)

Automate GitHooks

- https://gist.github.com/noelboss/3fe13927025b89757f8fb12e9066f2fa

- https://www.digitalocean.com/community/tutorials/how-to-deploy-a-jekyll-site-using-git-hooks-on-ubuntu-16-04

- https://itnext.io/automate-deployment-with-webhooks-18735f1c7f84

Infrastructue as Code

- https://www.toptal.com/devops/terraform-jenkins-continuous-deployment
