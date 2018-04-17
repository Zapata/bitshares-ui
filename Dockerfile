FROM node:6 as build

RUN npm install -g cross-env
ADD . /bitshares-ui
WORKDIR /bitshares-ui
RUN cross-env npm install --env.prod
RUN npm run build

FROM nginx:alpine
COPY --from=build /bitshares-ui/build/dist /usr/share/nginx/html
ADD conf/nginx.conf /etc/nginx/nginx.conf