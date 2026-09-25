docker build -t titikhuni-be .

docker run --rm -p 8080:8080 --env-file .env -e DB_HOST=host.docker.internal -e APP_URL=http://localhost:8080 titikhuni-be