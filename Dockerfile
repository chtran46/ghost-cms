FROM ghost:4 as cloudinary
WORKDIR $GHOST_INSTALL/current
RUN su -c yarn node -- add ghost-storage-cloudinary@2

FROM ghost:4
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/current/node_modules $GHOST_INSTALL/current/node_modules
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/current/node_modules/ghost-storage-cloudinary $GHOST_INSTALL/current/content/adapters/storage/ghost-storage-cloudinary
RUN set -ex; \
    su -c ghost node -- config storage.active ghost-storage-cloudinary; \
    su -c ghost node -- config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su -c ghost node -- config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su -c ghost node -- config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su -c ghost node -- config storage.ghost-storage-cloudinary.fetch.quality auto; \
    su -c ghost node -- config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true;
