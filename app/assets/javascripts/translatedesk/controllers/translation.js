//
angular.module('translatedesk.controllers').controller('TranslationController', ['$scope', '$location', 'Tweet', function($scope, $location, Tweet) {

  $scope.workbench = Tweet.workbench;
  
  $scope.prepareTranslation = function(t) {
    var hashtags = [],
        mentions = [];
    if (t && t.entities) {
      if (t.entities.hashtags) {
        for (var i=0; i < t.entities.hashtags.length; i++) {
          hashtags.push('#' + t.entities.hashtags[i].text);
        }
      }
      if (t.entities.user_mentions) {
        for (var i=0; i < t.entities.user_mentions.length; i++) {
          mentions.push('@' + t.entities.user_mentions[i].screen_name);
        }
      }
    }
    $scope.translatedTweet = (t ? 'TT @' + t.user.screen_name + ' ' + hashtags.concat(mentions).join(' ') : '');
  };

}]);
