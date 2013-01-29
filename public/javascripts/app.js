(function(window, document) {

  window.app = window.app || {};

  app.models = {};
  app.collections = {};
  app.views = {};

  var MainRouter = Backbone.Router.extend({

    routes: {
      '': 'home',
      'search/:query': 'search'
    },

    home: function() {
      console.log('home');
    },

    search: function(query) {
      console.log('search:', query);
    }
  });

  // app initialization
  
  app.router = new MainRouter();

  // TODO: fetch models, collections, etc
  
  $(document).ready(function() {

    Backbone.history.start({pushState: true});
    
  });
  

})(window, document);