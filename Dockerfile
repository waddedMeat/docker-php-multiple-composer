# use a build arg to set the image used
ARG IMAGE
FROM $IMAGE as web

# install app dependencies
# and make sure you clean up after yourself
RUN apt-get update && apt-get install -y \
    zip; \
    \
    rm -rf /var/lib/apt/lists/*

# do whatever you need to do
# you won't have to do this too often if you can make use of build cache
RUN perl -pi -e 's/(DocumentRoot).*$/$1 \/var\/www\/public/' /etc/apache2/sites-available/000-default.conf


#####
FROM web as builder

# things should be ordered by odds of changing
# docker will use build cache until it hits something that has changed
WORKDIR /var/www

# docker-compose only passes build args, not env vars
# so you have to do a little dance to set the composer env var
# the COMPOSER var will determine the name of the composer.json and lock files
ARG COMPOSER
ENV COMPOSER $COMPOSER
ARG COMPOSER_INSTALL_FLAGS

# install composer
ADD https://getcomposer.org/download/2.0.9/composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

# only copy what you need
# if docker determines there are no changes, we will continue to use cache
COPY .env composer*.* /var/www/

# run the build command
RUN composer install $COMPOSER_INSTALL_FLAGS


#####
# dev is based directly off of the builder
# this allows composer to be avaliable to install/upgrade packages
FROM builder as dev

# the WORKDIR is not inherited
WORKDIR /var/www


#####
# the last section is always the "default" target
# it will get run if you do not specify a target
# this is the "prod" section and will not contain anything from the build image
FROM web as prod

WORKDIR /var/www

# copy over the files from the build image
COPY --from=builder /var/www/vendor /var/www/vendor
# and bring in the rest of the files as well
COPY . /var/www
