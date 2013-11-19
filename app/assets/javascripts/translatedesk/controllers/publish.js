//
angular.module('translatedesk.controllers').controller('PublishController', ['$scope', '$location', '$window', 'Post', function($scope, $location, $window, Post) {

  $scope.posts = [];
  $scope.sortCriteria = 'popularity';
  $scope.sortOrder = 'reverse';
  $scope.searchLimit = 20;

  // Get original posts
  $scope.fetch = function() {
    Post.prototype.$fetch($scope.postQuery, { count : $scope.searchLimit })
    .success(function(data, status, headers, config) {
      $scope.posts = data;
    })
    .error(function(data, status, headers, config) {
      $scope.message = 'Could not fetch data';
    });
  };

  // Override default behavior, which is sorting by strings
  $scope.sortQueue = function(p) {
    result = p[$scope.sortCriteria];
    if (isNaN(result)) return result;
    return parseInt(result);
  };

  $scope.filter = {};
  $scope.filterQueue = function(p) {
    for (var filter in $scope.filter) {
      if ($scope.filter[filter] && (!p[filter] || (typeof $scope.filter[filter] == 'string' && $scope.filter[filter] != p[filter]))) return false;
    }
    return true;
  };

  $scope.loadConversation = function(p) {
    Post.prototype.$conversation(p.id_str)
    .success(function(data, status, headers, config) {
      p.conversation = data;
    });
  };

  $scope.workbench = Post.workbench;

  $scope.translate = function(p) {
    $scope.workbench.source = p;
    $window.scrollTo(0, 0);
  };

  $scope.filterTemplateUrl = function() {
    return '/assets/translatedesk/providers/' + $scope.workbench.provider.id + '/filters.html';
  };

  $scope.postTemplateUrl = function() {
    return '/assets/translatedesk/providers/' + $scope.workbench.provider.id + '/post.html';
  };

}]);
