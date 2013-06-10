//
angular.module('translatedesk.controllers').controller('TwitterController', ['$scope', '$location', 'Tweet', function($scope, $location, Tweet) {

  $scope.tweets = [];
  $scope.sortCriteria = 'popularity';
  $scope.sortOrder = 'reverse';
  $scope.searchLimit = 20;

  // Get tweets from Twitter, not from our database
  $scope.fetch = function() {
    Tweet.prototype.$fetch($scope.tweetQuery, { count : $scope.searchLimit })
    .success(function(data, status, headers, config) {
      $scope.tweets = data;
    })
    .error(function(data, status, headers, config) {
      $scope.message = 'Could not fetch data';
    });
  };

  // Override default behavior, which is sorting by strings
  $scope.sortQueue = function(t) {
    result = t[$scope.sortCriteria];
    if (isNaN(result)) return result;
    return parseInt(result);
  };

  $scope.filterQueue = function(t) {
    for (var filter in $scope.filter) {
      if ($scope.filter[filter] && !t[filter]) return false;
    }
    return true;
  };

  $scope.loadConversation = function(t) {
    Tweet.prototype.$conversation(t.id_str)
    .success(function(data, status, headers, config) {
      t.conversation = data;
    });
  };

}]);
