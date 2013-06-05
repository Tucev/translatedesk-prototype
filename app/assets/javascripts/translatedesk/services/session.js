angular.module('translatedesk.services').service('Session',[ '$cookieStore', 'UserSession', 'UserRegistration', function($cookieStore, UserSession, UserRegistration) {

  this.currentUser = $cookieStore.get('_angular_devise_user');
  this.signedIn = !!$cookieStore.get('_angular_devise_user');
  this.signedOut = !this.signedIn;
  this.userSession = new UserSession({});
  this.userRegistration = new UserRegistration( { email:"foo-" + Math.floor((Math.random()*10000)+1) + "@bar.com", password:"example", password_confirmation:"example" } );

}]);
