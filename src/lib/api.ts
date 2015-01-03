import express = require('express');

module.exports = (config: any) => {
	var apiServer = express();
	apiServer.set('config', config);
	
	apiServer.listen(config.port.api);
};