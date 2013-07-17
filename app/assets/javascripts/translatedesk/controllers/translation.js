//
angular.module('translatedesk.controllers').controller('TranslationController', ['$scope', '$location', '$timeout', 'Tweet', 'TweetDraft', function($scope, $location, $timeout, Tweet, TweetDraft) {

  $scope.workbench = Tweet.workbench;
  
  $scope.prepareTranslation = function(t) {

    if (!t) {
      return false;
    }

    // Try to load a saved draft first
    TweetDraft.prototype.$get(t.id)
    .success(function(data, status, headers, config) {
      if (data.text) {
        $scope.translatedTweet = data.text; 
      }
      else {
        // Pre-populate the new translation, if no draft is found
        var hashtags = [],
            mentions = [];
        if (t.entities) {
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
        $scope.translatedTweet = (t ? 'TT @' + t.user.screen_name + ' ' + hashtags.concat(mentions).join(' ') + ' ' : '');
      }
      $timeout(autoSave, 10000);
    })
    .error(function(data, status, headers, config) {
      alert('Sorry, some error happened, please try again.');
    });
  };

  // FIXME: This should not be necessary... it should work out-of-the-box... right?
  $scope.updateModel = function(text) {
    $scope.translatedTweet = text;
  };

  $scope.lastSave = {
    text : '',
    time : null,
    ago : null
  };
  var autoSave = function() {
    if ($scope.lastSave.text != $scope.translatedTweet) {
      TweetDraft.prototype.$save($scope.translatedTweet, $scope.workbench.source.id)
      .success(function(data, status, headers, config) {
        if (data.saved) {
          $scope.lastSave.time = new Date;
          $scope.lastSave.text = $scope.translatedTweet;
        }
        $timeout(autoSave, 10000);
      })
      .error(function(data, status, headers, config) {
        $timeout(autoSave, 10000);
      });
    }
    else {
      $timeout(autoSave, 10000);
    }
    if ($scope.lastSave.time) {
      $scope.lastSave.ago = moment($scope.lastSave.time).fromNow();
    }
  };

}]);
