// Twitter provider

App.providers.twitter = {

  id : 'twitter',
  name : 'Twitter',
  isDefault : true,
  charsLimit : 140,

  prepopulate : function(t) {
    var hashtags = [],
        mentions = [];
    if (t.entities) {
      if (t.entities.hashtags) {
        for (var i=0; i < t.entities.hashtags.length; i++) {
          hashtags.push('#' + t.entities.hashtags[i].text);
        }
      }
      if (t.entities.user_mentions) {
        for (var i=0; i < t.entities.user_mentions.length; i++) {
          mentions.push('@' + t.entities.user_mentions[i].screen_name);
        }
      }
    }
    return (t ? 'TT @' + t.user.screen_name + ' ' + hashtags.concat(mentions).join(' ') + ' ' : '');
  },

  transformResponse : function(Post, data) {
    // FIXME: Is there a better way to iterate?
    for (var i = 0; i < data.length; i++) {
      // Set additional data for the post
      data[i].popularity = ((t.retweet_count || 0) + (t.favorite_count || 0));
      data[i].created_at = Date.parse(data[i].created_at);
      data[i].media_count = (data[i].entities && data[i].entities.media && data[i].entities.media.length);
      data[i].urls_count = (data[i].entities && data[i].entities.urls && data[i].entities.urls.length);
      data[i].is_not_reply = !data[i].in_reply_to_status_id;
      if (Post.userPosition && data[i].geo) {
        data[i].distance = haversine(data[i].geo.coordinates[0], data[i].geo.coordinates[1], Post.userPosition.coords.latitude, Post.userPosition.coords.longitude).toFixed(2);
      }
    }
    return data;
  }

};
