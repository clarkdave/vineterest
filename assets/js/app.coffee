
((window,document) -> 

  window.app = window.app || {};

  app.models = {};
  app.collections = {};
  app.views = {};

  MainRouter = Backbone.Router.extend
    routes: {
      '': 'home',
      'search/:query': 'search'
    }
    home: ->
      console.log 'home'
    search: (query) ->
      console.log 'search', query


  app.router = new MainRouter()

  $(document).ready ->
    Backbone.history.start({pushState: true})

)(window, document)