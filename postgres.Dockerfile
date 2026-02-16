FROM postgres:latest

# copy script
COPY ./data/init-multiple-databases.sh /usr/local/bin/init-multiple-databases.sh
RUN chmod +x /usr/local/bin/init-multiple-databases.sh

# 
COPY ./data/docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper.sh

ENTRYPOINT ["docker-entrypoint-wrapper.sh"]
CMD ["postgres"]
