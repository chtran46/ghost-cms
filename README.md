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

```Shell
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


```Shell
cd $GHOST_INSTALL
mv config.production.json /var/lib/ghost/content/config.production.json
ln -s ./content/config.production.json config.production.json
```

## Optionally, create an image from container

`docker ps` to get the id of the running container

Run `docker commit` to save your image - see [https://docs.docker.com/engine/reference/commandline/commit/](https://docs.docker.com/engine/reference/commandline/commit/)