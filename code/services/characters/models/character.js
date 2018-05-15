'use strict';
module.exports = (sequelize, DataTypes) => {
  var character = sequelize.define('character', {
    name: DataTypes.STRING,
    gender: DataTypes.STRING,
    species: DataTypes.TEXT,
    occupations: DataTypes.STRING,
    location: DataTypes.INTEGER
  }, {
    classMethods: {
      associate: function(models) {
        // associations can be defined here
      }
    }
  });
  return character;
};