FROM php:7.2-fpm-alpine3.11

#Diretorio Atual e remove pasta html caso seja criada
WORKDIR /var/www
RUN rm  -rf /var/www/html

#Baixa as dependencias
RUN apk update && apk add --no-cache \
    nginx \
    git \
    curl \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install mbstring exif pcntl bcmath gd

#Baixa e instala o composer
COPY composer.json .
COPY --from=composer:latest  /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --no-autoloader

#Configura nginx
COPY ./.deploy/default-prod.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx/

#Cópia todos os arquivos do diretório atual
COPY . .

#Executa comandos necessários
RUN cp .env.prod .env
RUN chown -R www-data:www-data .
RUN composer dump-autoload
RUN ["chmod", "+x", "./entrypoint.sh"]

# Init entrypoint (nginx and php-fpm)
CMD ["./entrypoint.sh"]


EXPOSE 80
