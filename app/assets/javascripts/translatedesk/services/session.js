angular.module('translatedesk.services').service('Session',[ '$cookieStore', 'UserSession', 'UserRegistration', function($cookieStore, UserSession, UserRegistration) {

  this.currentUser = { data : $cookieStore.get('_angular_devise_user') };
  this.signed = { 
                  in  : !!$cookieStore.get('_angular_devise_user'),
                  out : !this.in
                };
  if (this.signed.in) {
    // We need to get fresh data from the server
    this.currentUser.data = UserSession.prototype.$show(this.currentUser.data.id);
  }
  this.userSession = new UserSession({});
  this.userRegistration = new UserRegistration();

}]);
