FROM php:7.2-fpm-alpine

#Diretorio Atual e remove pasta html caso seja criada
WORKDIR /var/www
RUN rm  -rf /var/www/html

#Cópia todos os arquivos do diretório atual
COPY . .

#Baixa as dependencias
RUN apk update && apk add \
    nginx \
    git \
    curl \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip

#Configura nginx
COPY ./.deploy/default-prod.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx/

# Install PHP extensions
RUN docker-php-ext-install mbstring exif pcntl bcmath gd

#Baixa e instala o composer
COPY --from=composer:latest  /usr/bin/composer /usr/bin/composer

#Executa comandos necessários
RUN rm -rf composer.lock
RUN cp .env.prod .env
RUN chown -R www-data:www-data .
RUN composer install --optimize-autoloader --no-dev
RUN ["chmod", "+x", "./entrypoint.sh"]

# Init entrypoint (nginx and php-fpm)
CMD ["./entrypoint.sh"]

EXPOSE 80
