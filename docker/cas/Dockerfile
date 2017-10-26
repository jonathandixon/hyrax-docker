FROM apereo/cas:v4.2.2

# Add our CAS configurations
COPY etc/* /etc/cas/

# Update the CAS overlay with our customizations.
COPY overlay /cas-overlay

# The extended container will start the CAS Jetty server
