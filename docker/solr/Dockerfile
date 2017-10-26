FROM solr:6.1

COPY config /opt/solr/server/solr/mycores/development
COPY config /opt/solr/server/solr/mycores/test

USER root
RUN chown -R $SOLR_USER:$SOLR_USER /opt/solr/server/solr/mycores/*

USER $SOLR_USER
