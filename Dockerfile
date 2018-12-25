FROM php:7.3-fpm

MAINTAINER "倒霉狐狸(mail@xiaoliu.org)"

# 改系统时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

# 升级系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y libfreetype6-dev libgmp-dev libjpeg62-turbo-dev libpng-dev libxml2-dev libcurl3-dev libbz2-dev

# 安装常用扩展
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) \
	iconv \
	gd \
	pdo \
	pdo_mysql \
	xml \
	mbstring \
	bcmath \
	curl \
	session \
	bz2 \
	calendar \
	fileinfo \
	gettext \
	gmp \
	json \
	opcache \
	pcntl \
	sockets
# 安装redis扩展
ENV PHPREDIS_VERSION 4.2.0
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
    && rm -rf /usr/src/php #如果这段不加构建的镜像将大100M

# 修改PHP的时区
RUN printf '[PHP]\ndate.timezone = "Asia/Shanghai"\n' > /usr/local/etc/php/conf.d/tzone.ini

# 清理产生数据
RUN apt-get purge -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        -o APT::AutoRemove::SuggestsImportant=false \
        $buildDeps \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove \
    && apt-get clean
