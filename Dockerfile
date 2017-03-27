FROM readytalk/nodejs

WORKDIR /app
ADD . /app
RUN npm install
EXPOSE 51000
ENTRYPOINT ["/app/boot.sh"]