# Version: 0.1.0


# Image setup
FROM debian:latest
MAINTAINER Denis Tokarev <d.tokarev@i-free.com>


# Code from root
USER root
CMD ["/bin/bash", "-l"]
RUN \
	rm /bin/sh && \
	ln -s /bin/bash /bin/sh

RUN apt-get update && \
	apt-get install -y \
		apt-utils \
		nginx \
		findutils \
		git \
		python \
		curl \
		make

VOLUME ["/mnt/host"]

RUN \
	groupadd -r appuser -g 433 && \
	useradd -u 431 -r -g appuser -d /home/appuser -s /bin/bash -c "Docker image user" appuser && \
	mkdir -p /home/appuser && \
	chown -R appuser:appuser /home/appuser


# Code from user
USER appuser
CMD ["/bin/bash", "-l"]
RUN \
	touch ~/.profile && \
	touch ~/.bashrc

CMD mkdir -p /home/appuser/source 
CMD ln -s /mnt/host/project /home/appuser/source/project

CMD curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
CMD source ~/.bashrc
CMD source ~/.profile
CMD nvm install 5.1.0
CMD nvm alias default 5.1.0
CMD npm i -g sails
CMD npm i -g babel
CMD npm i -g pm2
CMD npm i -g bower
CMD npm i -g grunt
CMD npm i -g gulp

WORKDIR ["/home/appuser/source/project"]
CMD cd /home/appuser/source/project
CMD sails


# Code from root
USER root
EXPOSE 80
ADD /home/appuser/source/project.conf /etc/nginx/sites-available/project.conf
CMD ln -s /etc/nginx/sites-available/project.conf /etc/nginx/sites-enabled/project.conf
CMD service nginx restart
CMD usermod -s /sbin/nologin appuser

ENTRYPOINT ["sails", "lift"]
