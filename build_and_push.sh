#!/bin/bash

docker login

docker pull php:8.5-fpm

docker build -t jsantoso/php-8.5-fpm:latest .

docker push jsantoso/php-8.5-fpm:latest
