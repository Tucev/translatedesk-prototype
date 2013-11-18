//
angular.module('translatedesk.controllers').controller('SessionsController', ['$scope', '$location', '$cookieStore', '$window', 'Session', function($scope, $location, $cookieStore, $window, Session) {
  
  $scope.session = Session.userSession;
  $scope.signed = Session.signed;
  $scope.currentUser = Session.currentUser;

  $scope.create = function() {
    if (!$scope.signed.in) {
      $scope.session.$save()
      .success(function(data, status, headers, config) {
        $cookieStore.put('_angular_devise_user', data);
        $scope.currentUser.data = data;
        $scope.signed.in = true;
        $scope.message = 'Logged in successfully';
      })
      .error(function(data, status, headers, config) {
        $scope.message = 'Sorry, could not login';
      });
    }
    else {
      $scope.message = 'You are already logged in';
    }
  };

  $scope.destroy = function() {
    $scope.session.$destroy()
    .success(function(data, status, headers, config) {
      $scope.signed.in = false;
      $scope.message = 'Logged out';
    })
    .error(function(data, status, headers, config) {
      $scope.message = 'Could not logout';
    });
  };

  $scope.providers = $window.App.providers;

}]);
