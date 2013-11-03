@Notable.module("Scaffold", (Scaffold, App, Backbone, Marionette, $, _) ->
	# Private --------------------------
	Scaffold.startWithParent = false

	class Scaffold.MessageView extends Marionette.Layout
		template: "scaffold/message"
		id: "message-center"
		tagName: "section"
		regions:
			notificationRegion: "#notification-region"
			modviewRegion: "#modview-region"

		events: ->
			"click .sidebar-toggle": "shiftNavbar"
			"click .new-note": "showTooltip"
			"click .outline_icon": "applyModview"
			"click .mindmap_icon": "applyModview"
			"click .grid_icon": "applyModview"

		showTooltip: ->
			$(".new-note").tooltip 'toggle'
		applyModview: (e) ->
			type = e.currentTarget.classList[1]
			$(".alert").text(type+" modview is displayed").show()
			$(".alert").delay(7000).fadeOut(1400)
			$(".modview-btn").removeClass("selected")
			$(".#{type}").addClass("selected")
		shiftNavbar: (e) ->
			$(".navbar-header").toggleClass("navbar-shift")
			$(".navbar-right").toggleClass("navbar-shift")
			type = e.currentTarget.classList[1]
			$(".#{type}").toggleClass("selected")

	class Scaffold.ContentView extends Marionette.Layout
		template: "scaffold/content"
		id: "content-center"
		tagName: "section"
		regions:
			treeRegion: "#tree-region"
			dirtRegion: "#dirt-region"

	class Scaffold.SidebarView extends Marionette.Layout
		template: "scaffold/sidebar"
		tagName:	"section"
		id: "sidebar-center"
		regions:
			notebookRegion: "#notebook-region"
			recentNoteRegion: "#recentNote-region"
			favoriteRegion: "#favorite-region"
			tagRegion: "#tag-region"

	# Initializers -------------------------
	App.Scaffold.on "start", ->
		messageView = new App.Scaffold.MessageView
		App.messageRegion.show messageView
		contentView = new App.Scaffold.ContentView
		App.contentRegion.show contentView
		sidebarView = new App.Scaffold.SidebarView
		App.sidebarRegion.show sidebarView
)
