//
angular.module('translatedesk.resources').factory('Tweet', ['$http', function($http) {

  var Tweet = function(options) {
    angular.extend(this, options);
  };

  Tweet.prototype.$fetch = function(query) {
    return $http.get('/tweets/fetch', {
      params : { 
        query : query
      }
    });
  };

  return Tweet;

}]);
