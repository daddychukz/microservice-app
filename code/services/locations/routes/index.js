var models  = require('../models');
var express = require('express');
var router  = express.Router();

router.get('/', function(req, res) {
    res.status(200).send({
        message: 'API ready to receive requests',
      })
});

router.get('/api/locations', function(req, res) {
    models.locations.all()
    .then(function(location) {
      res.status(200).send(location);
    }).catch(() => res.status(404).send({
      message: 'Locations Not Found!'
    }));
  });

  router.get('/api/locations/:id', function(req, res) {
    models.locations.findOne({
      where: {
        id: req.params.id
      }
    }).then(function(id) {
        res.status(200).send(id);
    });
  });

router.post('/api/locations', function(req, res) {
    models.locations.create({
        name: req.body.name,
        description: req.body.description
    })
    .then(location => res.status(200).send({
        message: 'Location Successfully Added',
        location }))
    .catch(err => res.status(400).send(err));
});

module.exports = router;