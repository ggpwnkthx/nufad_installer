FROM debian:buster-slim

LABEL maintainer "Isaac Jessup <ibjessup@gmail.com>"
LABEL description "NUFAD - Nginx, uWSGI, Flask powered API on Debian"

RUN apt-get update
RUN apt-get install -y \
	python3.7-minimal \
	python3-pip \
	nginx \
	uwsgi \
	uwsgi-plugin-python3 \
	supervisor \
	git \
	sudo

# Copy python requirements file
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt
RUN rm -r /root/.cache
	
# Copy the Nginx global conf
COPY nginx.conf /etc/nginx/
# Copy the Flask Nginx site conf
COPY flask-site-nginx.conf /etc/nginx/conf.d/
# Copy the base uWSGI ini file to enable default dynamic uwsgi process number
COPY uwsgi.ini /etc/uwsgi/
# Custom Supervisord config
COPY supervisord.conf /etc/supervisord.conf

COPY bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh

WORKDIR /app
CMD ["sh", "/bootstrap.sh"]
