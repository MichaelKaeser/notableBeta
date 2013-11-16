
@Notable.module("Action", (Action, App, Backbone, Marionette, $, _) ->

	# NOTES AND EXPLANATION:
	# -- all undo histories have a action TYPE, and CHANGE 
	#   	history item example: {type: '<<undoActionType>>', change: {object containing only relevant change info} }
	#	-- at the beginning of each undo action should be a list of EXPECTS 
	# 		(attributes expected to be found in 'change')
	# -- the general pattern for updating changes is:
	#			1 - get note reference
	#  		2 - add inverse action to redoStack
	#			3 - remove note from tree
	#			4 - update with attributes
	#			5 - insert the note again
	#  		6 - reset focus on the correct note
	#		-***- to improve the pattern for SOME actions only ie: content updates, don't remove or add, just trigger update

	_undoStack = []
	_redoStack = []
	_historyLimit = 100
	_revert =  {}
	_addAction = {}

	# -----------------------------
	# Action: createNote
	# -----------------------------
	# EXPECTS change: {guid: guid}
	_addAction.createNote = (note, isRedo = false) ->
		history = { type: 'createNote', changes: {guid: note.get('guid') } }
		if isRedo then _redoStack.push(history) else _undoStack.push(history)

	_revert.createNote = (change) ->
		reference = _getReference(change.guid)
		_addAction.deleteBranch reference.note, true

		App.Note.tree.deleteNote reference.note, true
		# set cursor 
		if reference.parent isnt 'root'
			App.Note.eventManager.trigger "setCursor:#{reference.parent_id}"
		else
			App.Note.eventManager.trigger "setCursor:#{App.Note.tree.first().get('guid')}"


	# -----------------------------
	# undo deleted branch
	# -----------------------------
	# EXPECTS change: {ancestorNote: {<ancestorNote attributes>}, childNoteSet: [list of child notes + attributes] }
	_addAction.deleteBranch = (note, isRedo = false) ->
		removedBranchs = {ancestorNote: note.getAllAtributes(), childNoteSet: []}
		completeDescendants = note.getCompleteDescendantList()
		_.each completeDescendants, (descendant) ->
			removedBranchs.childNoteSet.push(descendant.getAllAtributes())
			# App.OfflineAccess.addToDeleteCache descendant.get('guid'), true  << this should be handled in .destroy()
		history = {type: 'deleteBranch', changes: removedBranchs}
		if isRedo then _redoStack.push(history) else _undoStack.push(history)
		# App.Action.addHistory('deleteBranch', removedBranchs)
		# App.Notify.alert 'deleted', 'warning'

	_revert.reverseDeleteNote = (attributes) ->
		newBranch = new App.Note.Branch()
		newBranch.save(attributes)
		App.Note.tree.insertInTree newBranch
		#remove from storage if offline
		App.OfflineAccess.addToDeleteCache attributes.guid, false
		App.Note.eventManager.trigger "setCursor:#{newBranch.get('guid')}"			

	_revert.deleteBranch = (change) ->
		_revert.reverseDeleteNote(change.ancestorNote)
		_addAction.createNote _getReference(change.ancestorNote.guid).note, true
		for attributes in change.childNoteSet
			@reverseDeleteNote(attributes)



	# -----------------------------
	# undo move note
	# -----------------------------
	# EXPECTS change: {guid:'', parent_id:'', rank:'', depth: ''}
	_addAction.moveNote = (note, isRedo = false) ->
		history = {type: 'moveNote', changes: note.getPositionAttributes()}
		if isRedo then _redoStack.push(history) else _undoStack.push(history)

	_revert.moveNote = (change) ->
		reference = _getReference(change.guid)
		_addAction.moveNote reference.note, true

		App.Note.tree.removeFromCollection reference.parentCollection, reference.note
		reference.note.save change
		App.Note.tree.insertInTree reference.note

		App.Note.eventManager.trigger "setCursor:#{reference.note.get('guid')}"



	# -----------------------------
	# undo note content update
	# -----------------------------
	# EXPECTS change: {guid: '', title:'', subtitle:''}
	_addAction.updateContent = (note, isRedo = false) ->
		history = {type: 'updateContent', changes: note.getContentAttributes()}
		if isRedo then _redoStack.push(history) else _undoStack.push(history)

	_revert.updateContent = (change) ->
		reference = _getReference(change.guid)
		_addAction.updateContent reference.note, true

		App.Note.tree.removeFromCollection reference.parentCollection, reference.note
		reference.note.save change
		App.Note.tree.insertInTree reference.note

		App.Note.eventManager.trigger "setCursor:#{reference.note.get('guid')}"



	# -----------------------------
	#   HELPERS
	# -----------------------------

	_getReference = (guid) ->
		note = App.Note.tree.findNote(guid)
		parent_id = note.get('parent_id')
		parentCollection = App.Note.tree.getCollection(parent_id)
		{note: note, parent_id: parent_id, parentCollection: parentCollection}


	clearRedoHistory = ->
		# _redoStack.reverse()
		# for item in _redoStack
		#   actionHistory.push _redoStack.pop()
		_redoStack = []



	# ----------------------
	# Public Methods & Functions
	# ----------------------
	@addHistory = (actionType, note) ->
		throw "!!--cannot track this change--!!" unless _addAction[actionType]?
		if _redoStack.length > 1 then clearRedoHistory()
		if _undoStack.length >= _historyLimit then _undoStack.shift()
		_addAction[actionType](note)
	
	@undo = ->
		throw "nothing to undo" unless _undoStack.length > 0
		change = _undoStack.pop()
		_revert[change.type](change.changes)

	@redo = ->
		throw "nothing to redo" unless _redoStack.length > 0
		change = _redoStack.pop()
		_revert[change.type](change.changes)


	@setHistoryLimit = (limit) ->
		throw "-- cannot set #{limit} " if isNaN limit
		_historyLimit = limit

	@getHistoryLimit = ->
		_historyLimit



	# -----------------------------
	#   TEST HELPERS -- don't erase or you break tests
	# -----------------------------
	@_getActionHistory = ->
		_undoStack

	@_getUndoneHistory = ->
		_redoStack

	@_resetActionHistory = ->
		_undoStack = []
		_redoStack = []



	# --------------------------------------------------
	#   LOCAL STORAGE / CACHED CHANGES HELPERS
	# --------------------------------------------------

	# @exportToLocalStorage = ->
	# 	window.localStorage.setItem 'actionHistory', JSON.stringify _undoStack

	Action.addInitializer ->
		console.log 'starting action manager'
		_undoStack = JSON.parse(window.localStorage.getItem('actionHistory')) ? []

	# as great as this idea is, it won't always work... 
	Action.addFinalizer ->
		console.log 'ending action manager'
		_redoStack = window.localStorage.setItem 'actionHistory', JSON.stringify _undoStack

)