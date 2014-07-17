/* global moment:true */

import Ember from 'ember';

export default Ember.Handlebars.makeBoundHelper(function(date, format) {
  return moment(date).format(format);
});
