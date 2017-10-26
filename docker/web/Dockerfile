FROM ruby:2.3.1

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    postgresql-client \
    redis-tools \
    nodejs \
    unzip \
    postgresql \
    ghostscript \
    libmagickcore-dev \
    mediainfo \
    clamav \
    libclamav-dev \
    ffmpeg \
    libreoffice

# Fixes: https://unix.stackexchange.com/q/342403
RUN apt-get install -y --no-install-recommends -t jessie-backports \
    openjdk-8-jre-headless \
    ca-certificates-java

# Install Harvard's FITS tool
ENV FITS_VERSION 1.0.5
RUN curl -L http://projects.iq.harvard.edu/files/fits/files/fits-${FITS_VERSION}.zip \
      > /tmp/fits-${FITS_VERSION}.zip && \
  unzip /tmp/fits-${FITS_VERSION}.zip -d /opt/ && \
  rm -rf /tmp/fits-${FITS_VERSION}.zip && \
  ln -s /opt/fits-${FITS_VERSION} /opt/fits
COPY fits /opt/fits-${FITS_VERSION}
RUN chmod 755 /opt/fits-${FITS_VERSION}/fits.sh

# Create/Update the clamav database.
# TODO: is this necessary, it is very slow.
# RUN /usr/bin/freshclam --quiet

# Setup the app directory.
ENV APP_DIR=/opt/hyrax \
    TEMP=/opt/hyrax/tmp
RUN mkdir -p ${APP_DIR}
WORKDIR ${APP_DIR}

# Setup directory for ruby gems. This is to improve performance of the container.
ENV BUNDLE_GEMFILE=$APP_DIR/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/opt/bundle
VOLUME ${BUNDLE_PATH}

EXPOSE 3000

COPY scripts /scripts

RUN chmod 700 /scripts/*.sh

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["server"]
