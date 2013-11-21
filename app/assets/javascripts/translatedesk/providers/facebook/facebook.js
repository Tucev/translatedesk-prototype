// Facebook provider

App.providers.facebook = {

  id : 'facebook',
  name : 'Facebook',
  isDefault : false,
  charsLimit : 1000, // FIXME: Find out this limit

  prepopulate : function(t) {
    return (t ? 'TT ' + t.user.screen_name + ': ' : '');
  },

  transformResponse : function(Post, data) {
    // FIXME: Is there a better way to iterate?
    for (var i = 0; i < data.length; i++) {
      // Set additional data for the post
      data[i].shares_count = data[i].shares ? data[i].shares.count : 0;
      data[i].likes_count = data[i].likes ? data[i].likes.data.length : 0;
      data[i].comments_count = data[i].comments ? data[i].comments.data.length : 0;
      data[i].popularity = data[i].shares_count + data[i].likes_count + data[i].comments_count;
      if (data[i].likes_count == 25) data[i].likes_count += '+';
      if (data[i].comments_count == 25) data[i].comments_count += '+';
      data[i].created_at = Date.parse(data[i].created_time);
      data[i].user = { screen_name : data[i].from.name, name : data[i].from.name, url : 'https://www.facebook.com/profile.php?id=' + data[i].from.id };
      data[i].text = data[i].message || data[i].name;
      data[i].id_str = data[i].id;
      if (Post.userPosition && data[i].place && data[i].place.location) {
        data[i].distance = haversine(data[i].place.location.latitude, data[i].place.location.longitude, Post.userPosition.coords.latitude, Post.userPosition.coords.longitude).toFixed(2);
      }
    }
    return data;
  }

};
