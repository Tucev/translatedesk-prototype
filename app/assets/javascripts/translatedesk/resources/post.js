// FIXME: Replace some methods by RESTFUL resources
angular.module('translatedesk.resources').factory('Post', ['$http', '$window', 'Session', function($http, $window, Session) {

  var Post = function(options) {
    angular.extend(this, options);
  };

  if (window.navigator.geolocation) {
    window.navigator.geolocation.watchPosition(
      function(position) {
        Post.userPosition = position;
      },
      function(error) {
        console.log(error);
      },
      { timeout : 5000 }
    );
  }

  Post.prototype.$fetch = function(query, options) {
    return $http.get('/posts/fetch', {
      params : {
        provider : Post.workbench.provider.id,
        query : query,
        'options[count]' : options.count,
        'options[lang]' : options.lang
      },
      transformResponse : $http.defaults.transformResponse.concat([
        function(data, headersGetter) {
          return Post.workbench.provider.transformResponse(Post, data);
        }
      ])
    });
  };

  Post.prototype.$conversation = function(post_id) {
    return $http.get('/posts/conversation', {
      params : { 
        provider : Post.workbench.provider.id,
        post_id : post_id
      }
    });
  };

  Post.prototype.$publish = function(source_language, target_language, original_text, original_post_id, original_post_author, text) {
    return $http.post('/posts', {
      provider : Post.workbench.provider.id,
      source_language : source_language,
      target_language : target_language,
      original_text : original_text,
      original_post_id : original_post_id,
      original_post_author : original_post_author,
      text : text
    });
  };

  Post.prototype.$preview = function(text, author) {
    return $http.get('/posts/preview', {
      params : { 
        provider : Post.workbench.provider.id,
        text : text,
        author : author
      }
    });
  };

  Post.prototype.$translations = function(post_id) {
    return $http.get('/posts/translations', {
      params : { 
        provider : Post.workbench.provider.id,
        post_id : post_id
      }
    });
  };

  Post.prototype.$annotate = function(text, post_id) {
    return $http.post('/annotations', {
      text : text,
      post_id : post_id
    });
  };

  // The post the user is working on right now
  // This is shared among controllers
  if (Session.signed.in) {
    Post.workbench = {
      source : Session.currentUser.data.queue.length ? Session.currentUser.data.queue[0] : null,
      provider : $window.App.providers[Session.currentUser.data.provider],
      queue : Session.currentUser.data.queue
    };
  }
  else {
    Post.workbench = {
      source : null,
      provider : null,
      queue : []
    };
  }
  Post.workbench.providers = $window.App.providers;
  for (p in Post.workbench.providers) {
    if (!Post.workbench.provider && Post.workbench.providers[p].isDefault) Post.workbench.provider = Post.workbench.providers[p];
  }

  return Post;

}]);
