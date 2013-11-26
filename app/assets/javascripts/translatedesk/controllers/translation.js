//
angular.module('translatedesk.controllers').controller('TranslationController', ['$scope', '$location', '$timeout', 'Post', 'PostDraft', 'MachineTranslation', function($scope, $location, $timeout, Post, PostDraft, MachineTranslation) {

  $scope.workbench = Post.workbench;

  // Some post was picked for translation  
  $scope.prepareTranslation = function(p) {

    if (!p) {
      return false;
    }

    $scope.originalPost = p;
    $scope.publishingMessage = ''; 

    // Try to load a saved draft first
    PostDraft.prototype.$get($scope.workbench.provider.id, p.id_str)
    .success(function(data, status, headers, config) {
      if (data.text) {
        $scope.translatedPost = $scope.lastSave.text = data.text; 
      }
      else {
        // Pre-populate the new translation, if no draft is found
        $scope.translatedPost = $scope.workbench.provider.prepopulate(p);
      }
      $timeout(autoSave, 10000);
    })
    .error(function(data, status, headers, config) {
      alert('Sorry, some error happened, please try again.');
    });

    // Load translations
    // FIXME: Add cache to avoid loading the same translations more than once
    Post.prototype.$translations(p.id_str)
    .success(function(data, status, headers, config) {
      $scope.translations = data; 
    })
    .error(function(data, status, headers, config) {
      alert('Sorry, some error happened on loading translations, please try again.');
    });
  };

  // FIXME: This should not be necessary... it should work out-of-the-box... right?
  $scope.updateModel = function(text) {
    $scope.translatedPost = text;
  };

  // Save a draft automatically
  $scope.lastSave = {
    text : '',
    time : null,
    ago : null
  };
  var autoSave = function() {
    if ($scope.lastSave.text != $scope.translatedPost) {
      PostDraft.prototype.$save($scope.workbench.provider.id, $scope.translatedPost, $scope.workbench.source.id_str)
      .success(function(data, status, headers, config) {
        if (data.saved) {
          $scope.lastSave.time = new Date;
          $scope.lastSave.text = $scope.translatedPost;
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
        MachineTranslation.prototype.$translate(that.machineTranslator.name, that.sourceLanguage, that.targetLanguage, that.originalPost.text)
        .success(function(data, status, headers, config) {
          if (data) {
            // FIXME: We need these two-assignments because otherwise two-way binding doesn't work... why?
            $scope.translatedPost = that.translatedPost = data.text;
            that.machineTranslationMessage = 'Translated, see above.';
          }
        })
        .error(function(data, status, headers, config) {
          that.machineTranslationMessage = 'Could not translate.';
        });
      }
    }
  };

  // When provider is changed, set the source language to be
  // the post language and the target to be the user language
  // if available and not set
  $scope.selectMachineTranslator = function() {
    if (!$scope.sourceLanguage && $scope.originalPost.lang) {
      $scope.sourceLanguage = $scope.originalPost.lang;
    }
    if (!$scope.targetLanguage) {
      $scope.targetLanguage = getTargetLanguage();
    }
  };

  // This is the function that actually submits a translation
  $scope.publish = function() {

    $scope.publishingMessage = 'Publishing...';
    $scope.sourceLanguage = $scope.originalPost.lang;
    $scope.targetLanguage = getTargetLanguage();

    Post.prototype.$publish($scope.sourceLanguage, $scope.targetLanguage, $scope.originalPost.text, $scope.originalPost.id_str, $scope.originalPost.user.screen_name, $scope.translatedPost)
    .success(function(data, status, headers, config) {
      if (data && data.published_url) {
        $scope.translations.push(data);
        $scope.lastSave.ago = null;
        $scope.publishingMessage = 'Translation published! <a href="' + data.published_url + '" target="_blank">See it online!</a>';
      }
      else if (data && data.error) {
        $scope.publishingMessage = 'Could not publish. Reason: ' + data.error;
      }
      else {
        $scope.publishingMessage = 'Your post was created, but probably not published. Please check online on the target site.';
      }
    })
    .error(function(data, status, headers, config) {
      $scope.publishingMessage = 'Some unknown error happened, please try again.';
    });

  };

  $scope.preview = function() {
    Post.prototype.$preview($scope.translatedPost, $scope.originalPost.user.screen_name)
    .success(function(data, status, headers, config) {
      $scope.previewContent = data.text;
    })
    .error(function(data, status, headers, config) {
      $scope.previewContent = 'Some unknown error happened, please try again.';
    });
    $('#preview').modal();
  };

  $scope.postTemplateUrl = function() {
    return '/assets/translatedesk/providers/' + $scope.workbench.provider.id + '/post.html';
  };

}]);
