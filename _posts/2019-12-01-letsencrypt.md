---
title: "LetsEncrypt certificate for nginx and CentOS 7"
excerpt: "Why pay more for certificates from a certificate authority?"
last_modified_at: 2019-11-27T09:45:06-05:00
tags: 
  - code
toc: true
---
<script>
    document.querySelectorAll('pre > code').forEach(function (codeBlock) {
    var button = document.createElement('button');
    button.className = 'copy-code-button';
    button.type = 'button';
    button.innerText = 'Copy';

    var pre = codeBlock.parentNode;
    if (pre.parentNode.classList.contains('highlight')) {
        var highlight = pre.parentNode;
        highlight.parentNode.insertBefore(button, highlight);
    } else {
        pre.parentNode.insertBefore(button, pre);
    }
});

function addCopyButtons(clipboard) {
    document.querySelectorAll('pre > code').forEach(function (codeBlock) {
        var button = document.createElement('button');
        button.className = 'copy-code-button';
        button.type = 'button';
        button.innerText = 'Copy';

        button.addEventListener('click', function () {
            clipboard.writeText(codeBlock.innerText).then(function () {
                /* Chrome doesn't seem to blur automatically,
                   leaving the button in a focused state. */
                button.blur();

                button.innerText = 'Copied!';

                setTimeout(function () {
                    button.innerText = 'Copy';
                }, 2000);
            }, function (error) {
                button.innerText = 'Error';
            });
        });

        var pre = codeBlock.parentNode;
        if (pre.parentNode.classList.contains('highlight')) {
            var highlight = pre.parentNode;
            highlight.parentNode.insertBefore(button, highlight);
        } else {
            pre.parentNode.insertBefore(button, pre);
        }
    });
}

if (navigator && navigator.clipboard) {
    addCopyButtons(navigator.clipboard);
} else {
    var script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/clipboard-polyfill/2.7.0/clipboard-polyfill.promise.js';
    script.integrity = 'sha256-waClS2re9NUbXRsryKoof+F9qc1gjjIhc2eT7ZbIv94=';
    script.crossOrigin = 'anonymous';
    script.onload = function() {
        addCopyButtons(clipboard);
    };

    document.body.appendChild(script);
}

</script>
<style>

pre {
    white-space: pre-wrap;
}

.copy-code-button {
    color: #272822;
    background-color: #FFF;
    border-color: #272822;
    border: 2px solid;
    border-radius: 3px 3px 0px 0px;

    /* right-align */
    display: block;
    margin-left: auto;
    margin-right: 0;
    margin-top: 2px;

    margin-bottom: -2px;
    padding: 3px 8px;
    font-size: 0.8em;
}

.copy-code-button:hover {
    cursor: pointer;
    background-color: #F2F2F2;
}

.copy-code-button:focus {
    /* Avoid an ugly focus outline on click in Chrome,
       but darken the button for accessibility.
       See https://stackoverflow.com/a/25298082/1481479 */
    background-color: #E6E6E6;
    outline: 0;
}

.copy-code-button:active {
    background-color: #D9D9D9;
}

.highlight-rouge pre {
    /* Avoid pushing up the copy buttons. */
    margin: 0;
}
</style>

<br />
----


## Easy LetsEncrypt Implementation

[LetsEncrypt](https://letsencrypt.org/) is a project from the [Internet Security Research Group (ISRG)](https://www.abetterinternet.org/). Certbot is coordinated by the [EFF](https://www.eff.org/). Both are very important groups, improving the security and privacy of the internet. LetsEncrypt offers free certificates, and has a very broad base of support across the entire industry due to disatisfaction with the state of Certificate Authorities. Even more importantly to your average person, it allows for automated renewal! You can add multiple names to the same certificate. Domain wildcard certs are possible, but not planning on covering it here.

## First things first

Ensure your DNS is correct. LetsEncrypt will do a quick test to make sure it's issuing the cert to the correct server, as a basic security test. Best to get it out of the way before everything else. HTTPS doesn't have to be setup just yet.

## Prep work
 
 If you haven't already, add EPEL. Then install certbot. In this case, for nginx.
 
~~~ bash
yum install epel-release
yum install certbot-nginx
~~~

certbox is LetsEncrypt's client, and does all the heavy lifting. We have to make some mild changes to the nginx configuration.

~~~ bash
nano /etc/nginx/nginx.conf
~~~

Now that the nginx config file is open, replace the server_name with your actual domain name.

~~~ apache
server_name _; 
~~~

Update to something like this:

~~~ apache
server_name example.com www.example.com;
~~~

Updates done? Good! Trust but verify. 

~~~ bash
nginx -t
~~~

If it tests good, make the changes live and open up the firewall. 

~~~ bash
systemctl reload nginx
firewall-cmd --add-service=http
firewall-cmd --add-service=https
firewall-cmd --runtime-to-permanent
~~~

Hopefully no errors. If so, you'll have to resolve them. 


## Certbox and getting your certs

Certbox is very simple and straightforward. You can add multiple domains by using the -d domain flag a couple times. Or just once. 

~~~ bash
certbot --nginx -d example.com -d www.example.com -d dev.example.com
~~~

Enter your email when prompted, hit A to agree to EFF terms, and Y or N to share your email with EFF. If you didn't sort out your DNS and open up the firewall, it will now fail. Or have a typo in a domain name, like I did the first time. Just rerun the same certbox command if that happens after you fix the issues.

If successful, it will also prompt you to enter 1 to allow HTTP or HTTPS, or 2 to redirect all HTTP traffic to HTTPS. Hit 1 until you're done testing. You can rerun it later to lock it to HTTPS after you thoroughly test your server using HTTPS. Speaking of which, go to [https://www.ssllabs.com/ssltest/analyze.html?d=example.net](https://www.ssllabs.com/ssltest/analyze.html?d=example.net) and put your domain in the link. By default, it should give you an A. Go through the results and check them thoroughly. 

## Setting up auto-renewal

LetsEncrypt only issues short term certificates. Which isn't an issue if your auto-enrollment is working correctly. Thankfully it's pretty easy!

Open up crontab

~~~ bash
EDITOR=nano crontab -e
~~~

Let's set it to check for renewal every morning at 1am. If it's going to expire in less than 30 days, it'll get renewed. This command will check, and do so quietly without bothering you with any notifications.

~~~
00 1 * * * /usr/bin/certbot renew --quiet
~~~



 