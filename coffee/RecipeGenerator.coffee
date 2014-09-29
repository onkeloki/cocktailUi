class RecipeGenerator
	instance = null
	@getInstance: () ->
		instance ?= new RecipeGenerator()
	constructor: () ->
		$("body").on "click", "#ingredientlist li .ad-remove-button", ()->
			UnsavedHelper.getInstance().setUnsaved()
			RecipeGenerator.getInstance().addIngredientToRecipe($(@).closest("li"))
		$("body").on "click", "#theRecipe li .ad-remove-button", ()->
			+UnsavedHelper.getInstance().setUnsaved()
			RecipeGenerator.getInstance().removeIngredientFromRecipe($(@).closest("li"))


	addIngredientToRecipe: (ingredient)->
		$("#theRecipe").append(ingredient)

	removeIngredientFromRecipe: (ingredient) ->
		$("#ingredientlist").append(ingredient)

	serializeRecipe: () ->
		getUsedIngredient = (listitem) ->
			uuid: $(listitem).data("uuid")
			cl: $(listitem).find("select").val()
		{
		uuid: $("form#recipe input[name='uuid']").val(),
		recipename: $("form#recipe  input[name='recipename']").val(),
		beforetext: $("form#recipe  input[name='beforetext']").val(),
		aftertext: $("form#recipe  input[name='aftertext']").val(),
		ingredientlist: (getUsedIngredient item for item in $("#theRecipe li"))
		}

	saveNewEmptyRecipeToConfig: (config) ->
		newEmptyRecipe = instance.getEmptyRecipe()
		instance.addRecipeToConfig config, newEmptyRecipe
		loadConfigsAftersave = ()->
			selectRecipeAfterLoad = ()->
				$("#" + newEmptyRecipe.uuid).click()
			Service.getInstance().loadConfigs(selectRecipeAfterLoad)

		Service.getInstance().saveConfig(config, loadConfigsAftersave)



	duplicateCurrentRecipe: () ->
		cfg = $("form#recipe").data("config");
		rec = RecipeGenerator.getInstance().serializeRecipe()
		rec.uuid = CocktailUi.getInstance().getUniQueId("recipe-")
		rec.recipename = "#{rec.recipename} copy"
		RecipeGenerator.getInstance().addRecipeToConfig(cfg, rec)
		laodConfigsAftersave = () ->
			selectRecipeAfterLoad = ()->
				$("#" + rec.uuid).click()
			Service.getInstance().loadConfigs(selectRecipeAfterLoad)
		Service.getInstance().saveConfig(cfg, laodConfigsAftersave)


	deleteCurrentRecipe: () ->
		cfg = $("form#recipe").data("config");
		rec = RecipeGenerator.getInstance().serializeRecipe()
		delete cfg.recipes[rec.uuid]
		laodConfigsAftersave = () ->
			gotoindex = ()->
				CocktailUi.getInstance().showArea(CocktailUi.AREA_INDEX)
			Service.getInstance().loadConfigs(gotoindex)
		Service.getInstance().saveConfig(cfg, laodConfigsAftersave)



	saveCurrentRecipe: () ->
		cfg = $("form#recipe").data("config");
		rec = RecipeGenerator.getInstance().serializeRecipe()
		RecipeGenerator.getInstance().addRecipeToConfig(cfg, rec)
		laodConfigsAftersave = () ->
			alert "Saved"
			selectRecipeAfterLoad = ()->
				$("#" + rec.uuid).click()
			Service.getInstance().loadConfigs(selectRecipeAfterLoad)
		Service.getInstance().saveConfig(cfg, laodConfigsAftersave)

	addRecipeToConfig: (cfg, rec) ->
		cfg["recipes"] = {} if not cfg.recipes?
		cfg.recipes[rec.uuid] = rec

	loadRecipeGenerator: (cfg, recipe) ->
		CocktailUi.getInstance().showArea(CocktailUi.AREA_CREATERECIPE)
		$("form#recipe").data("config", cfg)
		$("#ingredientlist").html("")
		$("#setupname").text(cfg.configname)
		instance.addIngredient pump for pump in ConfigHelper.getInstance().getPumps(cfg)
		instance.fillRecipeForm(recipe)

	fillRecipeForm: (recipe) ->
		$("#theRecipe").text("")
		$("form#recipe input[name=uuid]").val(recipe.uuid)
		$("form#recipe input[name=recipename]").val(recipe.recipename)
		$("form#recipe input[name=beforetext]").val(recipe.beforetext)
		$("form#recipe input[name=aftertext]").val(recipe.aftertext)
		$("#recipe-beforetext").val(recipe.beforetext)
		$("#recipe-aftertext").val(recipe.aftertext)
		restoreingredient = (ingredient)->
			RecipeGenerator.getInstance().addIngredientToRecipe($("#ingredient-#{ingredient.uuid}"))
			$("#ingredient-#{ingredient.uuid}").find("select").val(ingredient.cl)
		(restoreingredient ingredient for ingredient in recipe.ingredientlist) if recipe.ingredientlist?



	addIngredient: (pump) ->

		item = $("<li>").text(pump.name).data(pump).attr("id", "ingredient-#{pump.uuid}")
		item.prepend($("<div>").addClass("ad-remove-button glyphicon glyphicon-search").text(""))
		select = RecipeGenerator.getInstance().getClSelect()
		item.prepend(select)
		$("#ingredientlist").prepend(item)

	getClSelect: ()->
		ret = $("<select>")
		appendOption = (value, to) ->
			to.append($("<option>").val(value).text("#{value} cl"))
		(appendOption val, ret  for val in [1..50])
		ret

	getEmptyRecipe: ()->
		uuid = CocktailUi.getInstance().getUniQueId("recipe-")
		{
		"uuid": uuid,
		recipename: "New Cocktail"
		"aftertext": "",
		"beforetext": "",
		"ingredientlist": []
		}

