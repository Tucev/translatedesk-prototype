//
angular.module('translatedesk.resources').factory('Tweet', ['$http', function($http) {

  var Tweet = function(options) {
    angular.extend(this, options);
  };

  // Calculate popularity of a tweet
  var popularity = function(t) {
    return (t.retweet_count || 0) + (t.favorite_count || 0);
  };

  // Implementation of Haversine formula
  var haversine = function(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = (Math.PI/180) * (lat2 - lat1);
    var dLon = (Math.PI/180) * (lon2 - lon1);
    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos((Math.PI/180) * (lat1)) * Math.cos((Math.PI/180) * (lat2)) * 
            Math.sin(dLon/2) * Math.sin(dLon/2); 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    var d = R * c; // Distance in km
    return d;
  };

  if (window.navigator.geolocation) {
    window.navigator.geolocation.watchPosition(
      function(position) {
        Tweet.userPosition = position;
      },
      function(error) {
        console.log(error);
      },
      { timeout : 5000 }
    );
  }

  Tweet.prototype.$fetch = function(query) {
    return $http.get('/tweets/fetch', {
      params : { 
        query : query
      },
      transformResponse : $http.defaults.transformResponse.concat([
        function(data, headersGetter) {

            for (var i = 0; i < data.length; i++) { // FIXME: Is there a better way to iterate?
              data[i].popularity = popularity(data[i]);
              data[i].created_at = Date.parse(data[i].created_at);
              if (!Tweet.userPosition || !data[i].geo) data[i].distance = -1;
              else data[i].distance = haversine(data[i].geo.coordinates[0], data[i].geo.coordinates[1], Tweet.userPosition.coords.latitude, Tweet.userPosition.coords.longitude).toFixed(2);
            }

            return data;
        }
      ])
    });
  };

  return Tweet;

}]);
