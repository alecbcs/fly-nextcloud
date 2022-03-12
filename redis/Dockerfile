FROM redis:alpine

ENV REDIS_PASSWORD default-password

CMD ["sh", "-c", "exec redis-server --requirepass \"$REDIS_PASSWORD\""]