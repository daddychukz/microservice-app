FROM node:carbon

WORKDIR /srv
ADD . .
RUN npm install
ENV NODE_ENV=production
ENV configEnvVar=DATABASE_URL
ENV DATABASE_URL=postgres://postgres:chuks@192.168.1.88:5432/postgres?ssl=true
EXPOSE 8081
CMD ["node", "server.js"]
