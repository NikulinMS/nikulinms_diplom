FROM nginx:latest

# Configuration
COPY conf /etc/nginx
# Content
COPY content /usr/share/nginx/html

#Health Check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost/ || exit 1

EXPOSE 80