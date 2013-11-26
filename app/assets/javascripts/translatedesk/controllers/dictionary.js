//
angular.module('translatedesk.controllers').controller('DictionaryController', ['$scope', 'Post', 'Dictionary', function($scope, Post, Dictionary) {
  
  $scope.workbench = Post.workbench;

  // If the tweet to be translated has changed, look for these words on the dictionary
  $scope.$watch('workbench.source', function() {
    $scope.dictWords = [];
    if ($scope.workbench.source && $scope.workbench.source.lang) {
      $scope.message = 'Looking for words on the dictionary...'
      var text = $scope.workbench.source.text;
      // FIXME: This tokenization is very simple
      var words = text.replace(/http:\/\/[^\s]+/, '').replace(/\s@[^\s]+/, '').replace(/\s#[^\s]+/, '').split(/\W+/);

      if (words.length > 0) {
        // FIXME: Getting source language automatically from source here
        Dictionary.prototype.$words_meanings(words, $scope.workbench.source.lang, getTargetLanguage())
        .success(function(data, status, headers, config) {
          if (data == {}) {
            $scope.message = 'Nothing found'
          }
          else {
            $scope.message = ''
          }
          for (var word in data) {
            $scope.dictWords.push({ original : word, meaning : data[word].join(' / ') });
          }
        })
        .error(function(data, status, headers, config) {
          $scope.message = 'Could not get data from the dictionary';
        });
      }
      else {
        $scope.message = ''
      }
    }
  }, true);

  $scope.dictPattern = '';
  $scope.searchFilter = function(word) {
    var words = $scope.dictPattern.split(/\s*,\s*/);
    for (var i = 0; i < words.length; i++) {
      var regex = new RegExp(words[i], 'i');
      if (regex.test(word.original) || regex.test(word.meaning)) {
        return true;
      }
    }
    return false;
  };

  $scope.search = function() { 
    var words = $scope.dictPattern.split(/\s*,\s*/);
    if (words.length && $scope.workbench.source && $scope.workbench.source.lang) {
      $scope.message = 'Looking for words on the dictionary...'

      Dictionary.prototype.$words_meanings(words, $scope.workbench.source.lang, getTargetLanguage())
      .success(function(data, status, headers, config) {
        if (data == {}) {
          $scope.message = 'Nothing found'
        }
        else {
          $scope.message = ''
        }
        for (var word in data) {
          $scope.dictWords.push({ original : word, meaning : data[word].join(' / ') });
        }
      })
      .error(function(data, status, headers, config) {
        $scope.message = 'Could not get data from the dictionary';
      });
    }
  };

}]);
