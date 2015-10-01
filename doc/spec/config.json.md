Specification of config.json
====

```ls
theme-color:
session-key:
session-secret:
cookie_pass:
mongo:
  uri: # ex) mongodb://localhost/Misskey
  options:
    user:
    pass:
redis:
  host: # ex) localhost
  port:
port:
  web:
  api:
  streaming:
  redis:
public-config:
  env: # ex) production, development
  domain: # ex) misskey.xyz
  hostname: # including port
  url: # ex)  https://misskey.xyz
  api-url: # ex) https://api.misskey.xyz
  streaming-url: # ex) https://api.misskey.xyz:1207
  production-channel-url: # ex) https://misskey.xyz
  development-channel-url: # ex) https://misskey.xyz:1206
webappid:
```
