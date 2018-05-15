var models  = require('../models');
var express = require('express');
var router  = express.Router();

router.get('/', function(req, res) {
    res.status(200).send({
        message: 'Microservices App',
      })
});

router.get('/api/characters', function(req, res) {
    models.character.all()
    .then(function(characters) {
      res.status(200).send(characters);
    }).catch(() => res.status(404).send({
      message: 'Characters Not Found!'
    }));
  });

  router.get('/api/characters/:id', function(req, res) {
    models.character.findOne({
      where: {
        id: req.params.id
      }
    }).then(function(id) {
        res.status(200).send(id);
    });
  });

  router.get('/api/characters/location/:locationId', function(req, res) {
    models.character.findOne({
      where: {
        location: req.params.locationId
      }
    }).then(function(id) {
        res.status(200).send(id);
    });
  });

  router.get('/api/characters/gender/:gender', function(req, res) {
    models.character.all({
      where: {
        gender: req.params.gender.toLowerCase()
      }
    }).then(function(gender) {
        res.status(200).send(gender);
    });
  });
  
router.post('/api/characters', function(req, res) {
    models.character.create({
        name: req.body.name,
        gender: req.body.gender,
        species: req.body.species,
        occupations: req.body.occupations,
        location: req.body.location
    })
    .then(character => res.status(200).send({
        message: 'Character Successfully Added',
        character }))
    .catch(err => res.status(400).send(err));
});

module.exports = router;