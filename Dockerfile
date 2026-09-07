# Production static web server using lightweight Nginx Alpine
FROM nginx:alpine

# Copy custom Nginx configuration with SPA routing and compression
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled Flutter web release bundle
COPY build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
