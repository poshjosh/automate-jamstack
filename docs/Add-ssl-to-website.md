# Add SSL to Website created by automate-jamstack

### Requirements

- AWS account
- AWS S3 bucket website
- Route 53 hosted zone for AWS S3 bucket

If you created your website using the `automate-jamstack` tool, you should 
have all the above requirements in place.

### Steps

#### Request SSL Certificate | AWS Certificate Manager

We need an SSL certificate to use HTTPS. Fortunately AWS provide these for 
free - for AWS resources at least.

* You need to create the certificate in the `us-east-1` region.

* Go to AWS certificate manager under the `us-east-1` region.

* Click on "Request a certificate".

* Select "DNS validation".

* In the `Domain Name` section add both `<sitename>.com` and `*.<sitename>.com`.
Where `<sitename>` is the name of your website.

* Click "Next" and a new page displaying the certificates will load.

* Click on "Create record in Route 53".

* Once completed, it can take 30 minutes or more to propagate and for you to be 
able to use the SSL Certificate. Once verified on Route 53, validation status 
will be shown as success. (_You may need to refresh the page_).

#### Using a content delivery network | CloudFront

Cloudfront is a Content Delivery Network provided by AWS. It is used to deliver 
content to users around the globe. It caches content to increase performance. 
Create a Web distribution with Cloudfront.

* Go to Cloudfront.

* Click on "Create a Cloudfront Distribution".

* Under `Orgin Name` enter your bucket name `<sitename>.com.s3-website-us-east-2.amazonaws.com`.

* Under `Default Cache Behaviour -> Viewer -> Viewer protocol policy` select 
`Redirect HTTP to HTTPS`.

* Under `Settings -> Custom SSL Certificate` select the certificate you created earlier. (_It may take
a few minutes for the certificate to appear. It also has to be in AWS region: `us-east-1`_).

* Under `Settings -> Alternate Domain Names (CNAMEs)` enter your domain names e.g: 
`<sitename>.com` and `wwww.<sitename>.com`.

* Under `Settings -> Default root object` enter `index.html`.

* Click the Create distribution button at the bottom to create the distribution.

* Copy the distribution’s domain name in the Domain name column, and paste it in 
a browser’s address bar to test if your website shows as secure. You should see 
your website’s home page displayed by default. You’ll either see a https prefix 
or a padlock icon in your browser’s address bar, which indicates that the 
connection to the website is secure like you see below.

#### Configuring CloudFront to Use Your Own Domain | AWS Route 53

At this point, CloudFront is still directing traffic to your S3 bucket endpoint; 
it’s not using your custom domain. Let’s change that. Perhaps you want to use 
your own domain to distribute your website instead of the one provided by CloudFront. 
If so, you need to create an A record for the domain name you previously registered.

* Click on Hosted zone under DNS management in Route 53 dashboard to access your 
hosted zone(s) list.

* On the Hosted zones page, click on your domain name e.g `<sitename>.com` in the table. 
Doing so will redirect you to a page where you’ll create an A record type. An A record 
routes this domain’s incoming traffic to your CloudFront distribution.

* Now select any of your existing A records for your domain name i.e. `<sitename>.com` 
or `www.<sitename>.com`.

* For each of the select A records, do the following:

  * Under `Record type` select `A`.
  * Under `Route traffic to` select `Alias to CloudFront distribution`.
  * In the next input box, select your CloudFront distribution from the dropdown list.
  * Click save.

#### Ensuring Cloudfront always gets the latest version of website | Cloudfront

Cloudfront returns cached version of your website. This means that, if you update your 
s3 website, that update may not reflect. To ensure that Cloudfront always gets the latest
version of your website, you need to add an invalidation as follows:

* First go to your AWS CloudFront service.

* Then click on the CloudFront distribution you want to invalidate.

* In the "object path" text field, you can list the specific files e.g. `/index.html` or 
just use the wildcard `/*` to invalidate all (this forces cloudfront to get the latest 
from everything in your S3 bucket).

* Once you filled in the text field click on "Invalidate", after CloudFront finishes 
invalidating you'll see your changes the next time you go to the web page.



