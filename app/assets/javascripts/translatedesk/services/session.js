angular.module('translatedesk.services').service('Session',[ '$cookieStore', 'UserSession', 'UserRegistration', function($cookieStore, UserSession, UserRegistration) {

  this.currentUser = { data : $cookieStore.get('_angular_devise_user') };
  this.signed = { 
                  in  : !!$cookieStore.get('_angular_devise_user'),
                  out : !this.in
                };
  this.userSession = new UserSession({});
  this.userRegistration = new UserRegistration();

}]);
