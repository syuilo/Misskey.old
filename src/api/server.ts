import express = require('express');
import config = require('../config');

var apiServer = express();
apiServer.listen(config.port.api);
