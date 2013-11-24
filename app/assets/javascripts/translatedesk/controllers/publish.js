//
angular.module('translatedesk.controllers').controller('PublishController', ['$scope', '$location', '$window', 'Post', function($scope, $location, $window, Post) {

  $scope.posts = [];
  $scope.sortCriteria = 'popularity';
  $scope.sortOrder = 'reverse';
  $scope.searchLimit = 20;
  $scope.sourceLanguageHandler = 'provider'
  $scope.languages = {};

  // Get original posts
  $scope.fetch = function() {
    Post.prototype.$fetch($scope.postQuery, { count : $scope.searchLimit, lang : $scope.sourceLanguageHandler })
    .success(function(data, status, headers, config) {
      $scope.posts = data;
      $scope.languages = {};
      for (var i = 0; i < data.length; i++) {
        if (data[i].lang && !$scope.languages[data[i].lang]) $scope.languages[data[i].lang] = data[i].lang_name;
      }
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
