((window,document) -> 

  window.app = window.app || {};

  app.models = {
    Vine: Backbone.Model.extend({})

  }
  app.collections = {
    Vines: Backbone.Collection.extend
      model: app.models.Vine
      url: '/vines'
      fetch_in_progress: false
      fetchMore: ->
        # actually go fetch
        if !@fetch_in_progress
          @fetch_in_progress = true
          # vines = [{video: 'https://vines.s3.amazonaws.com/videos/2BB777E2-5E54-4730-8493-3A61C49EAA0E-15523-0000058F7621FF6A_1.0.3.mp4?versionId=4DvJrol_esYub0hTyTBfxkKP.hqluMHs', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''},{video: 'https://vines.s3.amazonaws.com/videos/2BB777E2-5E54-4730-8493-3A61C49EAA0E-15523-0000058F7621FF6A_1.0.3.mp4?versionId=4DvJrol_esYub0hTyTBfxkKP.hqluMHs', image: 'https://vines.s3.amazonaws.com/thumbs/DA95E76B-43C5-434D-BA7F-4825E1DDD267-5798-000007997610F998_1.0.3.mp4.jpg?versionId=AIc5wFVpr5sUeDsT9MgdEYClj9URtZja', title: 'Nottingham in the snow', tweet: 'this is a cool hip tweet #cool #hip', user: {url: 'cool', name: '@dave', image: 'test'}, tweet_url: '', vine_url: ''}]
          # @add vines
          # @fetch_in_progress = false
  }
  app.views = {
    HeaderView: Backbone.View.extend
      events:
        'submit': 'search'
      search: (evt) ->
        app.router.navigate('/search/test', {trigger: true})
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
            @playing_index = index
            @views[index].play()
            @buffer()
        element.on 'playing', =>
          index = @views.indexOf(element)
          if @playing_index > @views.length - 5
            @model.fetchMore()
          if @playing_index != index
            @views[@playing_index].pause()
            @playing_index = index
        element.on 'buffer', @buffer, this
      buffer: ->
        index = @playing_index + 1
        if index != 0 and index < @views.length
          @views[index].prepareVideo()
      initialize: ->
        @model.on 'add', (vine) =>
          view = new app.views.VineGridElement model:vine
          @views.push view
          @$el.append view.render().el
          @registerEventsForGridElement view
      render: ->
        @views = []

        view = new app.views.VineGridAbout()
        @$el.append view.render().el

        for model in @model.models
          view = new app.views.VineGridElement model:model
          @views.push view
          @$el.append view.render().el
        _.map(@views, @registerEventsForGridElement, this)
        # @views[0].play()
        
        $(window).scroll =>
          if $(window).scrollTop() + $(window).height() > $(document).height() - 100
            @model.fetchMore()
        this
    VineGridAbout: Backbone.View.extend
      tagName: 'li'
      template: _.template "
        <div class='dummy'></div>
        <div class='content'>
          <h3>Vineterest man</h3>
        </div>
        
      "
      render: ->
        @$el.html @template()
        this
    VineGridElement: Backbone.View.extend
      tagName: 'li'
      className: 'vine-grid-element'
      template: _.template "
        <div class='dummy'></div>
        <div class='media'>
          <img src='<%= image %>' alt=''>
          <div class='border'></div>
        </div>
        <div class='shadow'>
          <div class='tweet'>
            <a href='<%= tweet.url %>'><%= tweet.user.name %></a>: <%= tweet.text %>
          </div>
        </div>
      "
      videoElement: null
      playing: false
      focus: false

      events:
        'click': 'click'

      click: ->
        @renderVideoElement()
        if @focus
          @focus = false
          @pauseVideo()
        else
          @focus = true
          @playVideo()
        return false
      renderVideoElement: ->
        if !@videoElement?
          $("<video src='#{@model.get('video')}'></video>").insertAfter(@$('img'))
          @videoElement = @$('video')
          @videoElement.on 'waiting', _.bind(@waiting, this)
          @videoElement.on 'canplay', _.bind(@canplay, this)
          @videoElement.on 'ended', _.bind(@ended, this)
      pauseVideo: ->
        if @videoElement?
          @videoElement[0].pause()
      playVideo: ->
        if @videoElement?
          @videoElement[0].play()

          # scroll to it
          scrollTop = @videoElement.offset().top - 60
          currentScrollTop = $('body').scrollTop()
          if scrollTop > 500 and currentScrollTop < scrollTop + 500 and currentScrollTop > scrollTop - 500
            $('body').animate({ scrollTop: @videoElement.offset().top - 60  }, 'slow');

          @$('.shadow').addClass 'play'
          @trigger 'playing', this
          @trigger 'buffer', this
      canplay: ->
        @$('.shadow').removeClass 'loading'
      waiting: ->
        @$('.shadow').addClass 'loading'
      ended: ->
        @$('.shadow').removeClass 'play'
        @trigger 'ended', this
      playing: ->
        @trigger 'playing', this
      play: ->
        @focus = true
        @renderVideoElement()
        @playVideo()
      pause: ->
        if @videoElement
          @videoElement[0].pause()
        @focus = false
        @$('.shadow').removeClass 'play'
      prepareVideo: ->
        @renderVideoElement()
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
      vines = new app.collections.Vines()
      
      view = new app.views.VineGrid({model: vines})
      view.render()
      vines.fetch update:true
      $('#container').html(view.el)
      setTimeout (->
        vines.fetchMore()
        ), 5000
      
    search: (query) ->
      vines = new app.collections.Vines()
      vines.fetch()
      view.render()
      $('#container').html(view.el)


  app.router = new MainRouter()

  $(document).ready ->
    Backbone.history.start({pushState: true})

)(window, document)