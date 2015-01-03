import express = require('express');

module.exports = (config: any) => {
	var webServer = express();
	webServer.set('config', config);
	
	webServer.listen(config.port.web);
};