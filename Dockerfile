FROM rocker/r-ver:3.5.2

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
    default-jre


# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown', 'dplyr', 'magrittr', 'h2o', 'shinydashboard', 'shinycssloaders', 'iml', 'magrittr', 'data.table'))" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /homevalue_prediction /srv/shiny-server/

# Make the ShinyApp available at port 80
EXPOSE 80

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN sudo chmod +x /usr/bin/shiny-server.sh 
CMD ["/usr/bin/shiny-server.sh"]
