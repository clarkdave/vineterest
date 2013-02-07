var ics = require('iced-coffee-script'),
    Jungle = require('../lib/jungle'),
    jungle = new Jungle()
;


// TODO: bootstrap initial vines into the rendered HTML
exports.index = function(req, res){
  res.render('index');
};

/**
 * Get some Vines. Without any search parameters, this will just return a list of
 * recent Vines found on Twitter.
 *
 * With search parameters, this will grab Vines matching the search critera and return
 * a list of those instead.
 *
 * The response format is an array of 'Vine' objects:
 * {
 *   video: URL to the Vine mp4
 *   image: URL to an image thumbnail
 *   title: Title of the Vine
 *   tweet: Text from the tweet
 *   vine_url: Direct link to the Vine page
 *   twitter_url: Direct link to the twitter url
 *   time: datetime this vine was posted (tweeted)
 *   user: {
 *     screen_name: Twitter screen name
 *     image: URL to Twitter user's profile pic
 *   }
 * }
 * 
 * @param  {[type]} req [description]
 * @param  {[type]} res [description]
 * @return {[type]}     [description]
 */
exports.vines = function(req, res) {

  var search = req.param('search')
  ;

  jungle.getRecentVines(function(vines) {
    console.log(vines);
    res.send(200);
  });

};