FROM node:lts-alpine
WORKDIR /usr/src/app
ENV AWS_REGION=us-east-2
COPY package*.json ./
RUN npm install && mv node_modules ../
COPY . .
EXPOSE 3000
RUN chown -R node /usr/src/app
USER node
CMD ["node", "app.js"]
