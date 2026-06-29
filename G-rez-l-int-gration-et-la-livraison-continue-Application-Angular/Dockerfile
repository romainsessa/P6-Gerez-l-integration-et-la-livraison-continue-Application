FROM node:20-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build -- --configuration production

FROM nginxinc/nginx-unprivileged:alpine

COPY nginx/nginx.conf /etc/nginx/nginx.conf

COPY --from=build /app/dist/olympic-games-starter/browser /app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]