//
angular.module('translatedesk.resources').factory('UserSession', ['$http', function($http) {

  var UserSession = function(options) {
    angular.extend(this, options);
  };

  UserSession.prototype.$save = function() {
    return $http.post('/users/sign_in', {
      "user" : {
        "email" : this.email,
        "password" : this.password,
        "remember_me" : this.remember_me ? 1 : 0
      }
    });
  };

  UserSession.prototype.$destroy = function() {
    return $http.get('/users/sign_out');
  };

  return UserSession;

}]);

//
angular.module('translatedesk.resources').factory('UserRegistration', ['$http', function($http) {

  var UserRegistration = function(options) {
    angular.extend(this, options);
  };

  UserRegistration.prototype.$save = function() {
    return $http.post('/users', {
      "user" : {
        "name" : this.name,
        "email" : this.email,
        "password" : this.password,
        "password_confirmation" : this.password_confirmation
      }
    });
  };

  return UserRegistration;

}]);
