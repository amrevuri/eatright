var express = require('express');
var app = express();


var swaggerUi = require('swagger-ui-express');
var swaggerDocument = require('./swagger.json');


var EatRightController = require('./EatRightController');

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
app.use('/eatright', EatRightController);

module.exports = app;
