###
@Notable.module("Note.Router", (Router, App, Backbone, Marionette, $, _) ->
	class Router extends Backbone.Marionette.AppRouter
		appRoutes:
			"zoom/:guid": "zoomIn"
			"": "clearZoom"
)
###