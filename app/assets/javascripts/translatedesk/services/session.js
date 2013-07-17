angular.module('translatedesk.services').service('Session',[ '$cookieStore', 'UserSession', 'UserRegistration', function($cookieStore, UserSession, UserRegistration) {

  this.currentUser = $cookieStore.get('_angular_devise_user');
  this.signedIn = !!$cookieStore.get('_angular_devise_user');
  this.signedOut = !this.signedIn;
  this.userSession = new UserSession({});
  this.userRegistration = new UserRegistration();

}]);
