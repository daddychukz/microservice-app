const express = require('express');
const logger = require('morgan');
const bodyParser = require('body-parser');
const models  = require('./models');
const routes = require('./routes/index');

var router  = express.Router();
const app = express();
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use('/', routes);

const port = process.env.PORT || 8081;
app.set('port', port);


app.listen(port, () => {
  console.log(`The server is listening on port ${port}`);
});

module.exports = app;