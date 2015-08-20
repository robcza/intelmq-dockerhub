FROM ubuntu:14.04
MAINTAINER Robert Šefr <robert.sefr@outlook.com>

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y python-pip git build-essential python-dev redis-server python-zmq python-pycurl libcurl4-gnutls-dev supervisor && \
    apt-get clean  && \ 
    rm -rf /var/lib/apt/lists/ /tmp/ /var/tmp/*

#IntelMQ base setup
WORKDIR /tmp/
RUN git clone https://github.com/certtools/intelmq.git
WORKDIR /tmp/intelmq
RUN pip install -r REQUIREMENTS && \
    python setup.py install && \
    useradd -d /opt/intelmq -U -s /bin/bash intelmq && \
    chmod -R 0770 /opt/intelmq && \
    chown -R intelmq.intelmq /opt/intelmq

#ASN lookup setup
WORKDIR /tmp/
RUN pip install pyasn --pre && \
    pyasn_util_download.py --latest && \
    pyasn_util_convert.py --single *.bz2 ipasn.dat && \
    mkdir /opt/intelmq/var/lib/bots/asn_lookup && \
    mv /tmp/ipasn.dat /opt/intelmq/var/lib/bots/asn_lookup/ && \
    chown -R intelmq.intelmq /opt/intelmq/var/lib/bots/asn_lookup

#GEOIP lookup setup
ADD http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz GeoLite2-City.mmdb.gz
RUN gzip -d GeoLite2-City.mmdb.gz && \
    mkdir /opt/intelmq/var/lib/bots/maxmind_geoip && \
    mv GeoLite2-City.mmdb /opt/intelmq/var/lib/bots/maxmind_geoip/ && \
    chown -R intelmq.intelmq /opt/intelmq/var/lib/bots/maxmind_geoip/

#IntelMQ config
COPY startup.conf /opt/intelmq/etc/startup.conf
COPY runtime.conf /opt/intelmq/etc/runtime.conf
COPY pipeline.conf /opt/intelmq/etc/pipeline.conf
COPY system.conf /opt/intelmq/etc/system.conf
COPY defaults.conf /opt/intelmq/etc/defaults.conf
COPY harmonization.conf /opt/intelmq/etc/harmonization.conf
COPY BOTS /opt/intelmq/etc/BOTS
COPY intelmqstartup.sh /opt/intelmq/bin/intelmqstartup.sh
RUN chmod +x /opt/intelmq/bin/intelmqstartup.sh

#supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Start IntelMQ
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf", "-n"]
