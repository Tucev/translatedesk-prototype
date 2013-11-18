// Common functions
  
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
