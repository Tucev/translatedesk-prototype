//
angular.module('translatedesk.controllers').controller('RegistrationsController', ['$scope', '$location', '$cookieStore', 'Session', function($scope, $location, $cookieStore, Session) {

  $scope.registration = Session.userRegistration;
  $scope.signed = Session.signed;
  $scope.currentUser = Session.currentUser;

  $scope.create = function() {
    $scope.registration.$save()
    .success(function(data, status, headers, config) {
      $cookieStore.put('_angular_devise_user', data);
      $scope.currentUser.data = data;
      $scope.signed.in = true;
      $scope.message = 'Account created successfully';
    })
    .error(function(data, status, headers, config) {
      $scope.message = 'Could not sign in';
    });
  };

  $scope.destroy = function() {
    $scope.registration.$destroy();
  };

}]);
