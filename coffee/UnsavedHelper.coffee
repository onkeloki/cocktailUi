class UnsavedHelper
	instance = null
	@getInstance: () ->
		instance ?= new UnsavedHelper()

	denieIfUnsaved: (promoter) ->
		isunsaved = $("body").hasClass("unsaved")
		if isunsaved
			UnsavedHelper.getInstance().showDialog(promoter)
		return isunsaved

	showDialog: (promoter) ->
		des = confirm("unsaved stuff get lost, continue?")
		UnsavedHelper.getInstance().setSaved() if des
		$(promoter).click() if des


	setUnsaved: () ->
		$("body").addClass("unsaved")

	setSaved: () ->
		$("body").removeClass("unsaved")

$().ready () ->
	$("body").on "click", ".addPump", ()->
		UnsavedHelper.getInstance().setUnsaved()
	$("body").on "keyup", "#config input", ()->
		UnsavedHelper.getInstance().setUnsaved()
	$("body").on "keyup", "#recipe input", ()->
		UnsavedHelper.getInstance().setUnsaved()
	$("body").on "keyup", "#recipe select", ()->
		UnsavedHelper.getInstance().setUnsaved()

