# ghost-cms

My custom Ghost configuration.

This configuration is based on base Ghost plus Cloudinary integration. As I am running on RPi 4, SD card space is at a premium so I wanted to store content remotely.  Cloudinary was a good choice because of its neat [transformation capabilities](https://cloudinary.com/documentation/image_transformations).

Cloudinary integration is based off of [https://github.com/eexit/ghost-storage-cloudinary](https://github.com/eexit/ghost-storage-cloudinary). The Docker build as described on the page never worked for me for some reason. The `RUN su-exec node yarn add ghost-storage-cloudinary@2` seemed to freeze up during the build. Not sure for what reason. So instead followed the Install from Yarn step after container startup, then run some of the steps manually. Then create an image from the container.

## Base Image Dockerfile

``` Dockerfile
version: '3.1'

services:

  ghost:
    image: ghost:latest

    restart: always
    ports:
      - 2368:2368
    volumes:
      - ghost_data:/var/lib/ghost/content
    environment:
      - url
      - CLOUDINARY_URL

volumes:
  ghost_data:
```

Start container and connect to shell

## Run in Shell to install Cloudinary integration

``` Shell
cd $GHOST_INSTALL
yarn add ghost-storage-cloudinary@2 --network-timeout 100000
mkdir -p content/adapters/storage
mv node_modules/ghost-storage-cloudinary content/adapters/storage/ghost-storage-cloudinary
ghost config storage.active ghost-storage-cloudinary; \
ghost config storage.ghost-storage-cloudinary.useDatedFolder true; \
ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
ghost config storage.ghost-storage-cloudinary.upload.invalidate true; \
ghost config storage.ghost-storage-cloudinary.upload.folder blog-images; \
ghost config storage.ghost-storage-cloudinary.fetch.quality auto; \
ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true; \
ghost config storage.ghost-storage-cloudinary.fetch.secure true; \
ghost config imageOptimization.resize false; \
ghost config mail.transport SMTP; \
ghost config mail.options.service sendgrid; \
ghost config mail.options.host smtp.sendgrid.net; \
ghost config mail.options.port 465; \
ghost config mail.options.secure true; \
ghost config mail.options.auth.user apikey; \
ghost config mail.options.auth.pass <your mailserver password> \
ghost config mail.from <your mailfrom address>;
```

These are my configurations that I found useful.  See [https://github.com/eexit/ghost-storage-cloudinary](https://github.com/eexit/ghost-storage-cloudinary) documentation to understand what attributes mean.

## Optionally, make config.production.json permanent

The above `ghost config` commands updates the `config.production.json` configuration file. This can be lost (unless you create image from container). Here, after the above configuration, we can make move to `/var/lib/ghost/content` that is mounted on a disk volume and then create a soft link to it.

``` Shell
cd $GHOST_INSTALL
mv config.production.json /var/lib/ghost/content/config.production.json
ln -s ./content/config.production.json config.production.json
```

## Optionally, create an image from container

`docker ps` to get the id of the running container

Run `docker commit` to save your image - see [https://docs.docker.com/engine/reference/commandline/commit/](https://docs.docker.com/engine/reference/commandline/commit/)

## Theme

In addition to the configuration instructins above, this repo contains a modified Casper theme found in the subdirectory `casper-theme`

I made some modifications to include a commenting system

### Remark42

[https://remark42.com/](https://remark42.com/) 
[https://www.devbitsandbytes.com/setting-up-remark42-from-scratch/](https://www.devbitsandbytes.com/setting-up-remark42-from-scratch/) 
[https://quantonganh.com/2019/10/11/static-site-generator](https://quantonganh.com/2019/10/11/static-site-generator)

Modifications to hbs files to reference Cloudinary URLs and their responsive image sizing

### Cloudinary

[https://github.com/eexit/ghost-storage-cloudinary](https://github.com/eexit/ghost-storage-cloudinary) 
[https://cloudinary.com/](https://cloudinary.com/)

A circular progress bar on page posts

### Progress Bar

[https://dev.to/shantanu\_jana/circular-progress-bar-using-html-and-css-1oda](https://dev.to/shantanu_jana/circular-progress-bar-using-html-and-css-1oda) 
inspired by 
[https://blog.jaysinha.me/setup-ghost-blog-with-custom-domain-secured-by-cloudflare/](https://blog.jaysinha.me/setup-ghost-blog-with-custom-domain-secured-by-cloudflare/) 
and a css arrow found at 
[https://freebiesupply.com/blog/css-arrows/](https://freebiesupply.com/blog/css-arrows/)

An lightbox for the image galleries - instead of sending the viewer to a Cloudinary URL

### fslightbox

[https://fslightbox.com/javascript/documentation](https://fslightbox.com/javascript/documentation) 
inspired by 
[https://forum.ghost.org/t/fluidbox-on-london-theme/12278](https://forum.ghost.org/t/fluidbox-on-london-theme/12278) 
[https://moeen.salehi.pw/blog/how-to-add-lightbox-to-ghost-blog/](https://moeen.salehi.pw/blog/how-to-add-lightbox-to-ghost-blog/)

Search capabilities

### Ghosthunter

[https://github.com/jamwise/ghostHunter](https://github.com/jamwise/ghostHunter) 
[https://www.hauntedthemes.com/how-to-add-search-to-ghost-using-ghosthunter/](https://www.hauntedthemes.com/how-to-add-search-to-ghost-using-ghosthunter/) 
and getting a better looking search input 
[https://freefrontend.com/css-search-boxes/](https://freefrontend.com/css-search-boxes/) 
specifically inspired by 
[https://codepen.io/ahmadbassamemran/pen/rNjMXqg](https://codepen.io/ahmadbassamemran/pen/rNjMXqg)

### Theme Build Integration

Integrated with GitHub action that triggers on check in 
[https://github.com/TryGhost/action-deploy-theme](https://github.com/TryGhost/action-deploy-theme) 
modified due to how my repo is set up and a [PR](https://github.com/TryGhost/action-deploy-theme/pull/39) that is taking its time being accepted
[https://github.com/chtran46/action-deploy-theme](https://github.com/chtran46/action-deploy-theme) 
with the action yml configured as
[https://github.com/chtran46/ghost-cms/blob/main/.github/workflows/deploy-theme.yml](https://github.com/chtran46/ghost-cms/blob/main/.github/workflows/deploy-theme.yml)
