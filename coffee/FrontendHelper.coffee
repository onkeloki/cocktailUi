class FrontendHelper
	instance = null
	constructor: ()->
		$("body").on "click", ".expandpumplist", (e)->
			$(".pumplist").toggleClass("expand")
			e.preventDefault()
			e.stopPropagation()

		$("body").on "click", ".addPump", (e)->
			CocktailUi.getInstance().addPump(CocktailUi.getInstance().getEmptyPumpConfig())
			e.preventDefault()
			e.stopPropagation()

		$("body").on "click", ".navbar-brand", (e) ->
			return if UnsavedHelper.getInstance().denieIfUnsaved(this)
			CocktailUi.getInstance().showArea(CocktailUi.AREA_INDEX)

		$("body").on "click", ".addRecipe", (e) ->
			return  if UnsavedHelper.getInstance().denieIfUnsaved(this)
			e.preventDefault()
			e.stopPropagation()
			config = $(this).closest(".configuration").data("config")
			RecipeGenerator.getInstance().saveNewEmptyRecipeToConfig config


		$("body").on "click", ".globaldeletebutton", (e) ->
			e.preventDefault()
			e.stopPropagation()
			CocktailUi.getInstance().deleteButtonClick()

		$("body").on "click", ".globalsavebutton", (e) ->
			e.preventDefault()
			e.stopPropagation()
			CocktailUi.getInstance().saveButtonClick()

		$("body").on "click", ".globalduplicatebutton", (e) ->
			e.preventDefault()
			e.stopPropagation()
			CocktailUi.getInstance().duplicateButtonClick()

		$("body").on "click", ".availableRecipes li", (e)->
			return if UnsavedHelper.getInstance().denieIfUnsaved(this)
			recipe = $(this).data()
			$(".active").removeClass("active")
			$(@).addClass("active")
			config = $(this).closest(".configuration").data("config")
			RecipeGenerator.getInstance().loadRecipeGenerator(config, recipe)


		$("body").on "click", "#newConfig", (e) ->
			return if UnsavedHelper.getInstance().denieIfUnsaved(this)
			CocktailUi.getInstance().createNewConfig()

	@getInstance: () ->
		instance ?= new FrontendHelper()
	selectConfigFroMenu: (uuid) ->
		$("##{uuid} a").click()
	selectRecipeFromMenu: (uuid) ->
		$("##{uuid}").click()
