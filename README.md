![](misskey-logo.png)

[![Build Status](https://travis-ci.org/syuilo/Misskey.svg)](https://travis-ci.org/syuilo/Misskey)
[![Pull Requst Stats](http://issuestats.com/github/syuilo/Misskey/badge/pr?style=flat)](http://issuestats.com/github/syuilo/Misskey)
[![Issue Stats](http://issuestats.com/github/syuilo/Misskey/badge/issue?style=flat)](http://issuestats.com/github/syuilo/Misskey)
[![Dependency Status](https://gemnasium.com/syuilo/Misskey.svg)](https://gemnasium.com/syuilo/Misskey)

# Misskey

[![Join the chat at https://gitter.im/syuilo/Misskey](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/syuilo/Misskey)

**[Misskey](https://misskey.xyz/) is a mysterious Twitter-style SNS.**
It runs on Node.js.

Source code of Misskey image server has also been published: [syuilo/Misskey-Image](https://github.com/syuilo/Misskey-Image)

## Branches
* `master` - Stable version. Deployed to https://misskey.xyz/ .
* `develop` - Development version. Deployed to https://misskey.xyz:1206/ . Only this branch is accepting any Pull Request.

## Dependencies
[![Node.js](https://img.shields.io/badge/Node.js-0.12.0-blue.svg)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-2.6.9-blue.svg)](https://www.mongodb.org)
[![Redis](https://img.shields.io/badge/Redis-2.8.19-blue.svg)](http://redis.io)
[![GraphicsMagick](https://img.shields.io/badge/GraphicsMagick-1.3.20-blue.svg)](http://www.graphicsmagick.org)

## Available commands
* `npm install` - Install the dependencies
* `npm run build` - Build
* `npm test` - Run test
* `npm run watch` - Watch the files and build when they are changed.

## Contribution
We welcome your contributions.

* Report any problems to [Issue](https://github.com/syuilo/Misskey/issues)
* Send [Pull Request](https://github.com/syuilo/Misskey/pulls)

If you have any questions, please feel free to ask on [Issue](https://github.com/syuilo/Misskey/issues).

## API
Misskey provides web-based API.
[Documentation](doc/api.md) is available.

### Thirdparty libraries
#### .NET
* [M#](https://github.com/marihachi/msharp) - MisskeyAPI Library For C#

#### Node.js
* [misskey.ts](https://github.com/AyaMorisawa/Disskey/blob/master/src/misskey.ts-README.md) - A Misskey library for Node.js, written in TypeScript, developed for Disskey.

## Special thanks
古谷向日葵, 大室櫻子 (2014 June ~)

## License
[MIT](LICENSE)
