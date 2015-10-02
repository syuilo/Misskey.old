# Contributing

## Dependencies
[![Node.js](https://img.shields.io/badge/Node.js-0.12.0-blue.svg)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-2.6.9-blue.svg)](https://www.mongodb.org)
[![Redis](https://img.shields.io/badge/Redis-2.8.19-blue.svg)](http://redis.io)
[![GraphicsMagick](https://img.shields.io/badge/GraphicsMagick-1.3.20-blue.svg)](http://www.graphicsmagick.org)

## Commands for development
* `npm install` - Install npm dependencies
* `npm run build` - Build
* `npm test` - Run test
* `npm run watch` - Watch the files and build when they are changed.

## Branches
* `master` - Stable version, deployed to https://misskey.xyz/
* `develop` - Development version, deployed to https://misskey.xyz:1206/

Note that only `develop` branch is accepting any Pull Requests.

# 部屋のアイテム追加
- モデルの形式はobj+mtlとします。
- 単位はメートル法で作ってください。
- **エクスポート時は三角面化してください。**
