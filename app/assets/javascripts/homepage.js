//= require jquery
//= require underscore
//= require backbone
//= require show_errors

//= require i18n
//= require i18n/translations

window.ActionStream = require('action_stream');
$(document).ready(function(){
  new ActionStream();
});
