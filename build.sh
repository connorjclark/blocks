#!/bin/sh

dart pub get
rm -rf dist
mkdir dist
dart2js -m --out=dist/main.js web/main.dart
cp web/index.html web/styles.css dist
cp -r web/images dist
