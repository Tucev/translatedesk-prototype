//
var debug;
angular.module('translatedesk.controllers').controller('TwitterController', ['$scope', '$location', 'Tweet', function($scope, $location, Tweet) {

  $scope.tweets = [];

  // Get tweets from Twitter, not from our database
  $scope.fetch = function() {
    Tweet.prototype.$fetch($scope.tweetQuery)
    .success(function(data, status, headers, config) {
      $scope.tweets = data;
      $scope.message = 'Fetched ' + data.length + ' tweets';
    })
    .error(function(data, status, headers, config) {
      $scope.message = 'Could not fetch data';
    });
  };

}]);
