@Notable.module("Note", (Note, App, Backbone, Marionette, $, _) ->

	class Note.Breadcrumb extends Backbone.Model
		initialize: (branch) ->
			@attributes = {}
			if (route = branch.get('route'))?
				@set "route", route
			else
				@set "route", "#/zoom/#{branch.get('guid')}"
			@set "title", branch.get('title')
			@set "depth", branch.get('depth')

	class Note.Breadcrumbs extends Backbone.Collection
		model: Note.Breadcrumb
		initialize: (models, branch) ->
			@buildBreadcrumbs(branch) if branch isnt "root"
			@addRoot()

		addRoot: ->
			breadcrumb = new Note.Breadcrumb
				attributes:
					route: "#/"
					title: "My Notebook"
					depth: -1

				get: (attr) ->
					@attributes[attr]

			@add breadcrumb

		buildBreadcrumbs: (branch) ->
			breadcrumb = new Note.Breadcrumb branch
			@add breadcrumb
			return if branch.isARoot()
			@buildBreadcrumbs App.Note.tree.findNote branch.get 'parent_id'

		comparator: (breadcrumb) ->
			breadcrumb.get('depth')

)
