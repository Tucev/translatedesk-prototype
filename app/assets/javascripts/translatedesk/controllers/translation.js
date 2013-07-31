//
angular.module('translatedesk.controllers').controller('TranslationController', ['$scope', '$location', '$timeout', 'Tweet', 'TweetDraft', 'MachineTranslation', function($scope, $location, $timeout, Tweet, TweetDraft, MachineTranslation) {

  $scope.workbench = Tweet.workbench;

  // Some tweet was picked for translation  
  $scope.prepareTranslation = function(t) {

    if (!t) {
      return false;
    }

    $scope.originalTweet = t;

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

  // Save a draft automatically
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

  // Machine translation: translate using a machine translator, like Google Translate or Bing
  // Populate languages available for machine translation (depends on the provider)
  $scope.getMachineTranslators = function() {
    if (!$scope.machineTranslators) {
      MachineTranslation.prototype.$translators()
      .success(function(data, status, headers, config) {
        if (data) {
          $scope.machineTranslators = data;
        }
      })
      .error(function(data, status, headers, config) {
        $scope.machineTranslationMessage = 'Could not get list of providers.';
      });
    }
  };

  $scope.machineTranslate = function() {
    if (this.machineTranslator && this.sourceLanguage && this.targetLanguage) {
      if (confirm('The machine translation will replace the current translated text on the field above. Continue?')) {
        $scope.machineTranslationMessage = 'Translating...';
        MachineTranslation.prototype.$translate(this.machineTranslator.name, this.sourceLanguage, this.targetLanguage, this.originalTweet.text)
        .success(function(data, status, headers, config) {
          if (data) {
            $scope.translatedTweet = data.text;
            $scope.machineTranslationMessage = 'Translated, see above.';
          }
        })
        .error(function(data, status, headers, config) {
          $scope.machineTranslationMessage = 'Could not translate.';
        });
      }
    }
  };

  // When provider is changed, set the source language to be
  // the tweet language and the target to be the user language
  // if available and not set
  $scope.selectMachineTranslator = function() {
    if (!$scope.sourceLanguage && $scope.originalTweet.lang) {
      $scope.sourceLanguage = $scope.originalTweet.lang;
    }
    // FIXME: It's better to get the language from the server, using header HTTP_ACCEPT_LANGUAGE
    var language = window.navigator.userLanguage || window.navigator.language;
    if (!$scope.targetLanguage && language) {
      $scope.targetLanguage = language;
    }
  };

}]);
