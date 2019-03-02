ssh root@134.209.81.78


sftp root@134.209.81.78
lpwd



mkdir homeShinyApp
cd homeShinyApp

vi Dockerfile


docker build -t homevalue .

docker image ls

sudo docker run -p 80:80 homevalue
########################################################################################################################


# install dependencies
sudo apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget

# install R
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo apt-get update
sudo apt-get -y install r-base
sudo apt-get -y install default-jdk

# install Rstudio
sudo apt-get install -y gdebi libxml2-dev libssl-dev libcurl4-openssl-dev libopenblas-dev 
wget https://s3.amazonaws.com/rstudio-ide-build/server/bionic/amd64/rstudio-server-1.2.1310-amd64.deb
sudo gdebi rstudio-server-1.2.1310-amd64.deb

# open poort
ufw status
ufw allow  8787

sudo useradd -m ruser  
sudo passwd ruser
sudo chown -R ruser:ruser /home/ruser/homevalue_prediction
# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/



