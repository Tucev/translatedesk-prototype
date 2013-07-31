// FIXME: Replace some methods by RESTFUL resources
angular.module('translatedesk.resources').factory('MachineTranslation', ['$http', function($http) {

  var MachineTranslation = function(options) {
    angular.extend(this, options);
  };

  MachineTranslation.prototype.$translators = function() {
    return $http.get('/machine_translation/translators');
  };

  MachineTranslation.prototype.$translate = function(translator, source, target, text) {
    return $http.post('/machine_translation/translate', {
      translator : translator,
      source : source,
      target : target,
      text : text
    });
  };

  return MachineTranslation;

}]);
