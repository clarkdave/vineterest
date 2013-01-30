((window,document) -> 

  window.app = window.app || {};

  window.app.models = {
    Vine: Backbone.Model.extend({})

  }
  window.app.collections = {
    Vines: Backbone.Collection.extend
      model: window.app.models.Vine
      parse: (resp, options) ->
        @next = resp.pagination.next
        resp.data
      fetch_in_progress: false
      fetchMore: ->
        # actually go fetch
        if !@fetch_in_progress
          @fetch_in_progress = true
          vines = [{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''}]
          @add vines
          @fetch_in_progress = false
  }
  window.app.views = {
    HeaderView: Backbone.View.extend
      events:
        'submit': 'search'
      search: (evt) ->
        window.app.router.navigate('/search/test', {trigger: true})
        false

    VineGrid: Backbone.View.extend
      tagName: 'ul'
      className: 'vine-grid'
      views: []
      playing_index: 0
      registerEventsForGridElement: (element) ->
        element.on 'ended', =>
          index = @views.indexOf(element) + 1
          if index != 0 and index < @views.length
            @views[index].play()
        element.on 'playing', =>

          index = @views.indexOf(element)
          console.log 'playing'
          console.log index
          if @playing_index != index
            console.log 'hereka'
            @views[@playing_index].pause()
            @playing_index = index

      initialize: ->
        @model.on 'add', (vine) =>
          view = new window.app.views.VineGridElement model:vine
          @views.push view
          @$el.append view.render().el
      render: ->
        @views = []
        for model in @model.models
          view = new window.app.views.VineGridElement model:model
          @views.push view
          @$el.append view.render().el
        _.map(@views, @registerEventsForGridElement, this)
        @views[0].play()
        console.log 'sdsd'
        $(window).scroll =>
          if $(window).scrollTop() + $(window).height() > $(document).height() - 100
            @model.fetchMore()
        this

    VineGridElement: Backbone.View.extend
      tagName: 'li'
      template: _.template "
        <h4 class='subheader'><%= title %></h4>
        <div class='media'>
          <img src='<%= image %>' alt=''>
          <div class='border'></div>
        </div>
        <div class='tweet'>
          <a href='<%= user.url %>'><%= user.name %></a>:
          <p><%= tweet %></p>
        </div>
      "
      videoElement: null
      events:
        'click': 'play'
        'ended video': 'ended'
      ended: ->
        @trigger 'ended', this
      playing: ->
        @trigger 'playing', this
      play: ->
        # attach it to dom
        if !@videoElement?
          $("<video src='#{@model.get('video')}' autoplay>test</video>").insertAfter(@$('img'))
          @videoElement = @$('video')
          @videoElement.on 'ended', =>
            @ended()

        # focus on it
        scrollTop = @videoElement.offset().top - 60
        if scrollTop > 500
          $('body').animate({ scrollTop: @videoElement.offset().top - 60  }, 'slow');

        # play it
        @videoElement[0].play()
        @trigger 'playing', this
      pause: ->
        if @videoElement
          @videoElement[0].pause()
      initialize: ->

      render: ->
        @$el.html @template(@model.toJSON())
        setTimeout (=>
          @$el.addClass 'fadeIn'), 100
        this

  }

  MainRouter = Backbone.Router.extend
    routes: {
      '': 'home',
      'search/:query': 'search'
    }
    home: ->
      vines = new window.app.collections.Vines([{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''}])
      view = new window.app.views.VineGrid({model: vines})
      view.render()
      $('#container').html(view.el)
      setTimeout (->
        vines.fetchMore()
        ), 5000
      
    search: (query) ->
      vines = new window.app.collections.Vines([{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4?versionId=3ZgkjmBN6zh6xxBJhgLehVMOjH1cvXfb', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''}])
      view = new window.app.views.VineGrid({model: vines})
      view.render()
      $('#container').html(view.el)


  window.app.router = new MainRouter()

  $(document).ready ->
    view = new window.app.views.HeaderView el: $('header')
    view.render()
    Backbone.history.start({pushState: true})

)(window, document)