# docker-php-multiple-composer
Example of a dockerized PHP application with multiple composer files

The Dockerfile will package composer's vendor directory inside the image
When developing, source files are mounted into the container and the vendor direcory is mapped to a volume so they are not overwritten

Developers can run compser commands inside a container to add pacakges; the mounted lock file will get updated.

Composer does not exist in the production build; vendor files are included in the iamge.
