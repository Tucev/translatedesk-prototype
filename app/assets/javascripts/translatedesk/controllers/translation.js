//
angular.module('translatedesk.controllers').controller('TranslationController', ['$scope', '$location', '$timeout', 'Tweet', 'TweetDraft', 'MachineTranslation', function($scope, $location, $timeout, Tweet, TweetDraft, MachineTranslation) {

  $scope.workbench = Tweet.workbench;

  // Some tweet was picked for translation  
  $scope.prepareTranslation = function(t) {

    if (!t) {
      return false;
    }

    $scope.originalTweet = t;
    $scope.publishingMessage = ''; 

    // Try to load a saved draft first
    TweetDraft.prototype.$get(t.id_str)
    .success(function(data, status, headers, config) {
      if (data.text) {
        $scope.translatedTweet = $scope.lastSave.text = data.text; 
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

    // Load translations
    // FIXME: Add cache to avoid loading the same translations more than once
    Tweet.prototype.$translations(t.id_str)
    .success(function(data, status, headers, config) {
      $scope.translations = data; 
    })
    .error(function(data, status, headers, config) {
      alert('Sorry, some error happened on loading translations, please try again.');
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
      TweetDraft.prototype.$save($scope.translatedTweet, $scope.workbench.source.id_str)
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
    var that = this;
    if (that.machineTranslator && that.sourceLanguage && that.targetLanguage) {
      if (confirm('The machine translation will replace the current translated text on the field above. Continue?')) {
        that.machineTranslationMessage = 'Translating...';
        MachineTranslation.prototype.$translate(that.machineTranslator.name, that.sourceLanguage, that.targetLanguage, that.originalTweet.text)
        .success(function(data, status, headers, config) {
          if (data) {
            // FIXME: We need these two-assignments because otherwise two-way binding doesn't work... why?
            $scope.translatedTweet = that.translatedTweet = data.text;
            that.machineTranslationMessage = 'Translated, see above.';
          }
        })
        .error(function(data, status, headers, config) {
          that.machineTranslationMessage = 'Could not translate.';
        });
      }
    }
  };

  // Get target language
  // FIXME: It's better to get the language from the server, using header HTTP_ACCEPT_LANGUAGE
  var getTargetLanguage = function() {
    var language = window.navigator.userLanguage || window.navigator.language;
    if (language) {
      return language;
    }
    else {
      return 'en'; // Fallback to English as default
    }
  };

  // When provider is changed, set the source language to be
  // the tweet language and the target to be the user language
  // if available and not set
  $scope.selectMachineTranslator = function() {
    if (!$scope.sourceLanguage && $scope.originalTweet.lang) {
      $scope.sourceLanguage = $scope.originalTweet.lang;
    }
    if (!$scope.targetLanguage) {
      $scope.targetLanguage = getTargetLanguage();
    }
  };

  // This is the function that actually submits a translation
  $scope.publish = function() {

    $scope.publishingMessage = 'Publishing...';
    $scope.sourceLanguage = $scope.originalTweet.lang;
    $scope.targetLanguage = getTargetLanguage();

    Tweet.prototype.$publish($scope.sourceLanguage, $scope.targetLanguage, $scope.originalTweet.id_str, $scope.originalTweet.user.screen_name, $scope.translatedTweet)
    .success(function(data, status, headers, config) {
      if (data && data.twitter_url) {
        $scope.translations.push(data);
        $scope.lastSave.ago = null;
        $scope.publishingMessage = 'Tweet published! <a href="' + data.twitter_url + '" target="_blank">See it on Twitter!</a>';
      }
      else if (data && data.error) {
        $scope.publishingMessage = 'Could not publish. Reason: ' + data.error;
      }
      else {
        $scope.publishingMessage = 'Your tweet was created, but probably not published. Please check on Twitter.';
      }
    })
    .error(function(data, status, headers, config) {
      $scope.publishingMessage = 'Some unknown error happened, please try again.';
    });

  };

  $scope.preview = function() {
    Tweet.prototype.$preview($scope.translatedTweet, $scope.originalTweet.user.screen_name)
    .success(function(data, status, headers, config) {
      $scope.previewContent = data.text;
    })
    .error(function(data, status, headers, config) {
      $scope.previewContent = 'Some unknown error happened, please try again.';
    });
    $('#preview').modal();
  };

}]);
