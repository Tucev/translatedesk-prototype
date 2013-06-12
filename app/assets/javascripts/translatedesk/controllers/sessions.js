//
angular.module('translatedesk.controllers').controller('SessionsController', ['$scope', '$location', '$cookieStore', 'Session', function($scope, $location, $cookieStore, Session) {
  
  $scope.session = Session.userSession;
  $scope.isLoggedIn = Session.signedIn;

  $scope.create = function() {
    if (!$scope.isLoggedIn) {
      $scope.session.$save()
      .success(function(data, status, headers, config) {
        $cookieStore.put('_angular_devise_user', data);
        $scope.isLoggedIn = true;
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
      $scope.isLoggedIn = false;
      $scope.message = 'Logged out';
    })
    .error(function(data, status, headers, config) {
      $scope.message = 'Could not logout';
    });
  };

}]);
