# flutterflow-web-deploy

docker build --build-arg FLUTTER_VERSION=3.24.2 -t flutter-web-builder .

docker-compose up --build

deploy
deploy/app
deploy/morboseo-sdk
deploy/.env
deploy/build-flutter.sh
deploy/docker-compose.yml
deploy/Dockerfile