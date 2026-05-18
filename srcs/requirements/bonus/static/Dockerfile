FROM alpine:3.19

RUN apk update && apk add --no-cache nginx

# Copy nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy static site files
COPY site /var/www/static

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
