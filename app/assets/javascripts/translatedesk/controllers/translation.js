//
angular.module('translatedesk.controllers').controller('TranslationController', ['$scope', '$location', 'Tweet', function($scope, $location, Tweet) {

  $scope.workbench = Tweet.workbench;
  
  $scope.prepareTranslation = function(t) {
    var hashtags = [];
    if (t && t.entities && t.entities.hashtags) {
      for (var i=0; i < t.entities.hashtags.length; i++) {
        hashtags.push('#' + t.entities.hashtags[i].text);
      }
    }
    $scope.translatedTweet = (t ? 'TT @' + t.user.screen_name + ' ' + hashtags.join(' ') : '');
  };

}]);
