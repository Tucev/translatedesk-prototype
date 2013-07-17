// FIXME: Replace some methods by RESTFUL resources
angular.module('translatedesk.resources').factory('TweetDraft', ['$http', function($http) {

  var TweetDraft = function(options) {
    angular.extend(this, options);
  };

  TweetDraft.prototype.$save = function(text, original_tweet_id) {
    return $http.post('/tweet_drafts', {
      text : text,
      original_tweet_id : original_tweet_id
    });
  };

  // FIXME: Is it ok to pass the original tweet id instead of the draft id?
  TweetDraft.prototype.$get = function(original_tweet_id) {
    return $http.get('/tweet_drafts/' + original_tweet_id);
  };

  return TweetDraft;

}]);
