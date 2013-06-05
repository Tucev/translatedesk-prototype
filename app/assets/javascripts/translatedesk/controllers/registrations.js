//
var debug;
angular.module('translatedesk.controllers').controller('RegistrationsController', ['$scope', '$location', 'Session', function($scope, $location, Session) {

  $scope.registration = Session.userRegistration;

  $scope.create = function() {
    $scope.registration.$save()
    .success(function(data, status, headers, config) {
      $scope.message = 'Account created successfully, login above';
    })
    .error(function(data, status, headers, config) {
      $scope.message = 'Could not sign in';
    });
  };

  $scope.destroy = function() {
    $scope.registration.$destroy();
  };

}]);
