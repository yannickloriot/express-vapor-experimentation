FROM node:11.9

WORKDIR /usr/src/app

COPY package.json .
COPY package-lock.json .
RUN npm install

RUN mkdir views
COPY index.js .
COPY views/*.* ./views

ENV REDIS_HOSTNAME=redis
ENV REDIS_PORT=6379
EXPOSE 3000

CMD [ "npm", "start" ]