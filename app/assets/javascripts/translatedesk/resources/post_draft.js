// FIXME: Replace some methods by RESTFUL resources
angular.module('translatedesk.resources').factory('PostDraft', ['$http', function($http) {

  var PostDraft = function(options) {
    angular.extend(this, options);
  };

  PostDraft.prototype.$save = function(provider, text, original_post_id) {
    return $http.post('/post_drafts', {
      provider : provider,
      text : text,
      original_post_id : original_post_id
    });
  };

  // FIXME: Is it ok to pass the original post id instead of the draft id?
  PostDraft.prototype.$get = function(provider, original_post_id) {
    return $http.get('/post_drafts/' + original_post_id, { params : { provider : provider } });
  };

  return PostDraft;

}]);
