### Automate the deployment of markdown content as a static website to cloud based infrastructure ###

This application will help publish your markdown pages as a static website built with javascript and HTML effortlessly. Really at the click of a file. All you need are:

- An Amazon account (access key and secret key)

- A domain name (e.g _www.my-cool-website.com_) - optional

Caveat: _You need to have [docker](https://www.docker.com/) installed._

### Direct Usage ###

No need to build/compile anything here. But we need to set some properties first
so create a file called `sites/default-site.env` and place it in the directory
`sites`. Add the following properties for a start.
_Fill in values were they have been ommitted_

```
AWS_ACCESS_KEY=[VALUE REQUIRED]
AWS_SECRET_KEY=[VALUE REQUIRED]
AWS_S3_BUCKET_NAME=[VALUE REQUIRED]
AWS_REGION=[VALUE REQUIRED]
SITE_URL=https://poshjosh.github.io
AWS_S3_BUCKET_NAME_PREFIX=poshjosh-s3
PROFILE=dev
SITE_BACKGROUND_COLOR=#eeeeee
SITE_TWITTER_HANDLE=Chinomso
SITE_SOURCE=https://github.com/gatsbyjs/gatsby-starter-blog
SITE_MAX_WIDTH=590
SITE_TITLE=Poshjoshs-Blog-on-Software-Engineering
SITE_SHORT_NAME=Poshjoshs-Blog
SITE_HOME_PAGE=https://poshjosh.github.io
SITE_THEME_COLOR=#663399
SITE_ISSUES_URL=https://github.com/gatsbyjs/gatsby-starter-blog/issues
SITE_LINKS_TO_REPLACE=https://poshjosh.github.io
SITE_AUTHOR=Chinomso-Ikwuagwu
REFRESH=false
SITE_AUTHOR_SUMMARY=a-once-in-a-lifetime-opportunist
# Must not start with forward slash /
SITE_ICON_LOCATION=content/assets/site-icon.png
SITE_DIR_NAME=default-site
SITE_LINKS_REPLACEMENT=
SITE_PAGES_DIR=/content/blog
SITE_ASSETS_DIR=/content/assets
AWS_OUTPUT=json
SITE_NAME=Poshjoshs-Blog
APP_PORT=8000
SITE_REPOSITORY_TYPE=git
SITE_DESCRIPTION=Poshjosh-Blog-on-Software-Engineering
SITE_REPOSITORY_URL=git+https://github.com/gatsbyjs/gatsby-starter-blog.git
VERBOSE=false
AWS_UPDATE_S3_BUCKET=true
```

Now you are ready to get going. Just open a terminal/command prompt and
type the following command:

```
$ docker run --name poshjosh-automate-jamstack -it --rm -v "%cd%/site":/site -p 8000:8000 poshjosh/automate-jamstack
```

Now browse to http://localhost:8000 to view you website on your local machine.

If your browser complains with an error message like the following. You may need
to relax any restrictions you switch on in the browser, particularly regarding javascript.
Otherwise, try other browsers.

```
Failed to get service worker registration(s): Storage access is restricted in this context due to user settings or private browsing mode. app.js:41
[HMR] connected client.js:95
SecurityError: The operation is insecure. app.js:41
404 page could not be found. Checkout https://www.gatsbyjs.org/docs/add-404-page/ index.js:2177
    __stack_frame_overlay_proxy_console__ index.js:2177
    loadPageDataJson dev-loader.js:28
```    

I set tough privacy restrictions on my firefox and go the above error. So I opened another
browser (microsoft Edge) and ```Hello World``` was displayed

After basking in your first success. Take time out to read the advanced section
which follows.  

For useful links, see the reference section at the end of the page

### For more advanced users ###

The following steps will help you customize the website.

- Rename you markdown (pages having extension `.md`) pages to `sites/default-site/content/blog`

- Do not paste any `index.html` page as it will be auto generated for you. Pasting an index
page could interfer with the auto - generation process

- Rename any picture of yourself to `profile-pic.jpg` and place it in the
`sites/default-site/content/blog` directory, replacing any `profile-pic.jpg` therein.

- Rename you site icon to `site-icon.png` and place it in the `sites/default-site/content/assets` directory replacing any `site-icon.png` therein.

- To add styles do the following:

  ```
    └───src/
        └───components/
        │   │─  layout.js
  +     │   └─  layout.css   <-- Add this file here
        │
        └───pages/
            └─  index.js
  ```
  - Add a layout.css in the `sites/default-site/src/components` directory.

  - Import the layout into the `sites/default-site/src/components/layout.js` by
  adding `import "./layout.css"` to the top of `layout.js`

  - Enter styles to the `sites/default-site/src/components/layout.css` file e.g:

```
  div {
      background: #eeeeee;
      color: navy;
  }
```

- Take styling a step further by changing the typography (call it theme if you like)
of your website. [Click here](https://kyleamathews.github.io/typography.js/) to find
a selection of typography. To change the typography open file at
`sites/default-site/src/utils/typography.js` and change
`import Theme from "typography-theme-twin-peaks"` to any of the following:

```
  import Theme from "typography-theme-twin-peaks"
  import Theme from "typography-theme-lincoln"
  import Theme from "typography-theme-wordpress-2016"
  import Theme from "typography-theme-fairy-gates"
  import Theme from "typography-theme-grand-view"
```

- If you want to get your hands dirty with HTML, JavaScript, React, Graphql

  - Auto bio - `sites/default-site/src/components/bio.js`

  - Page layout - `sites/default-site/src/components/layout.js`

  - Blog post template - `sites/default-site/src/templates/blog-post.js`

### Some properties and their effects ###

VERBOSE - Causes a more verbose log

### Deploying to Amazon S3 ###

Change the profile property in the `sites/default-site.env` file you created earlier
from `PROFILE=dev` to production `PROFILE=prod`  

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
