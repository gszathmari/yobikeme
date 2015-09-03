FROM node:0.12

MAINTAINER Gabor Szathmari "gszathmari@gmail.com"

ENV APPLICATION_NAME yobikeme

COPY package.json /tmp/package.json
WORKDIR /tmp
RUN npm install
RUN mkdir /app && cp -R /tmp/node_modules /app
RUN npm install -g coffee-script forever

WORKDIR /app
COPY . /app
RUN coffee --bare --compile --output /app/lib/ /app/src/

CMD ["forever", "./lib/server.js"]

EXPOSE 8080
