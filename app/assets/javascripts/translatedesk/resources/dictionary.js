// FIXME: Replace some methods by RESTFUL resources
angular.module('translatedesk.resources').factory('Dictionary', ['$http', function($http) {

  var Dictionary = function(options) {
    angular.extend(this, options);
  };

  Dictionary.prototype.$words_meanings = function(words, from, to) {
    return $http.post('/dictionaries/words_meanings', {
      words : words,
      from : from,
      to : to
    });
  };

  return Dictionary;

}]);
