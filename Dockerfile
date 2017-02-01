# AUTOGENERATED BY MAKE - DO NOT MODIFY MANUALLY
FROM resin/amd64-alpine

# Install ZIM (wikipedia etc) packages
ENV ZIM_URL http://download.kiwix.org/zim

RUN mkdir -p /content/zim /content/kiwix /usr/src/kiwix \
 && apk add --update openssl \
 && KIWIX= \
 && BIN= \
 && if [ $(uname -m) = "x86_64" ]; then \
      KIWIX=kiwix-linux-x86_64 \
      ; BIN=kiwix/bin \
    ; else \
      KIWIX=kiwix-server-arm \
      ; BIN= \
      ; \
    fi \
 && wget -O - https://download.kiwix.org/bin/$KIWIX.tar.bz2 \
      | tar -C /usr/src/kiwix -xjf - \
 && mv /usr/src/kiwix/$BIN/* /usr/bin/ \
 && rm -rf /usr/src/kiwix \
 && for zim in wiktionary_en_simple_all.zim; do \
      wget -O /content/zim/$zim $ZIM_URL/$zim \
      && ls /content/zim \
      && kiwix-index  /content/zim/$zim /content/kiwix/index \
      && kiwix-manage /content/kiwix/library.xml add /content/zim/$zim \
      ; \
    done


# Install httrack
RUN apk add --update -t build-deps build-base zlib-dev openssl-dev \
 && wget -O - https://github.com/xroche/httrack/archive/3.48.21.tar.gz \
      | tar -C /usr/src -xzf - \
 && cd /usr/src/httrack-3.48.21 \
 && ./configure \
 && make -j8 \
 && make install \
 && apk del build-deps \
 && rm -rf /usr/src/*

# Mirror Websites
ENV SITES http://elpissite.weebly.com
RUN mkdir -p /content/www \
 && cd /content/www \
 && httrack --ext-depth=1 $SITES \
 && find . -type f -maxdepth 1 -delete \
 && rm -rf hts-cache \
 && cd /content/www/elpissite.weebly.com \
 && for f in *.html; do sed -i 's/class=\"footer-wrap\".*/class=\"footer-wrap\" style=\"display:none;\" \/>/' $f; done

### CAUTION: CHANGES ABOVE THIS LINE WILL BUST THE CACHE ###

RUN apk add --update hostapd dnsmasq s6 nginx openssh \
 && sed -i 's/#PermitRootLogin.*/PermitRootLogin\ yes/' \
      /etc/ssh/sshd_config

COPY files /

VOLUME [ "/data" ]
EXPOSE 80


ENTRYPOINT [ "/run.sh" ]
