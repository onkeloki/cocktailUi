class CocktailUi
	instance = null
	@AREA_INDEX = "index"
	@AREA_CONFIGEDITOR = "configeditor"
	@AREA_CREATERECIPE = "createrecipe"
	@getInstance: () ->
		instance ?= new CocktailUi()


	showArea: (areaName) ->
		$("body").alterClass("area-*")
		$("body").addClass("area-" + areaName)



	constructor: ()->
		$("#config").prepend @getConfigVarInput "startAll", "http://", "if your machine has a service to stop all pumps with one call, you can add the url here", "Start all pumps url"
		$("#config").prepend @getConfigVarInput "stopAll", "http://", "if your machine has a service to stop all pumps with one call, you can add the url here", "Stop all pumps url"
		$("#config").prepend @getConfigVarInput "miliSecondsPerCl", "http://", "milliseconds per cl. <br>example: If your machine needs 2 seconds to fill up 1 CL you need to enter 2000 (ms) here. (only the number)", "MS per CL"
		$("#config").prepend @getConfigVarInput "configname", "pumpsetup 1", "name of this setup", "Name"
		$("#config").prepend @getConfigVarInput "uuid", "uuid", "just stuff"
		FrontendHelper.getInstance()



	createNewConfig: () ->
		cfg = CocktailUi.getInstance().getNewConfig()
		loadAfitersave = ()->
			selectAfterload = ()->
				FrontendHelper.getInstance().selectConfigFroMenu(cfg.uuid)
			Service.getInstance().loadConfigs(selectAfterload)
		Service.getInstance().saveConfig(cfg, loadAfitersave)



	deleteButtonClick: () ->
		if $("body").hasClass("area-configeditor")
			Service.getInstance().deleteCurrentConfig()
		if $("body").hasClass("area-createrecipe")
			RecipeGenerator.getInstance().deleteCurrentRecipe()


	saveButtonClick: () ->
		if $("body").hasClass("area-configeditor")
			Service.getInstance().saveCurrentConfig()
		if $("body").hasClass("area-createrecipe")
			RecipeGenerator.getInstance().saveCurrentRecipe()

	duplicateButtonClick: () ->
		if $("body").hasClass("area-configeditor")
			Service.getInstance().duplicateCurrentConfig()
		if $("body").hasClass("area-createrecipe")
			RecipeGenerator.getInstance().duplicateCurrentRecipe()






	clearConfig: ()->
		CocktailUi.getInstance().loadConfig(CocktailUi.getInstance().getNewConfig())


	loadConfig: (@config) ->
		CocktailUi.getInstance().showArea(CocktailUi.AREA_CONFIGEDITOR)
		$(".pumplist").html("")
		(@setConfigValue data, @config[data] for data of  @config)
		if @config.pumps?
			(@addPump data for data in @config.pumps)

	setConfigValue: (key, val) ->
		$("input[name=" + key + "]").val(val)

	getEmptyPumpConfig: ()->
		uuid = CocktailUi.getInstance().getUniQueId("pump-")
		{
		"uuid": uuid,
		"name": "unnamed Pump",
		"startUrl": "",
		"stopUrl": ""
		}

	getNewConfig: () ->
		uuid = CocktailUi.getInstance().getUniQueId("config-")
		{
		"uuid": uuid,
		"configname": "unnamed Config",
		"stopAll": "",
		"startAll": "",
		"miliSecondsPerCl": 0,
		"pumps": []
		}

	getUniQueId: (prefix) ->
		s4 = () ->
			Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
		ausg = s4() + s4() + s4() + s4() + s4() + s4() + s4() + s4()
		prefix + ausg




	getConfigById: (id) ->
		return $("##{id}").data("config")




	getConfigFromForm: () ->
		result = CocktailUi.getInstance().getConfigById($("form#config input[name=uuid]").val());
		fillObject = (obj, result)->
			result[obj.name] = obj.value
		fillObject obj, result for obj in $("form#config").serializeArray()

		result.pumps = []
		collectPumps = (key, result) ->
			isPump = key.substr(0, 5) is "pump-"
			if isPump
				uuid = key.split("pump-").join("")
				uuid = uuid.split("]").join("")
				uuid = uuid.split("[")
				uuid = uuid[0]
				pumpObj = {
					uuid: "pump-" + uuid,
					startUrl: result["pump-#{uuid}[startUrl]"],
					stopUrl: result["pump-#{uuid}[stopUrl]"],
					name: result["pump-#{uuid}[name]"]
				}
				result["pumps"].push(pumpObj)
				delete result["pump-#{uuid}[startUrl]"]
				delete result["pump-#{uuid}[stopUrl]"]
				delete result["pump-#{uuid}[name]"]


		collectPumps key, result for key of result
		result.pumps.reverse()


		result


	parseResult = (input) ->
		(parseResult obj for obj of cfg)


	getConfigVarInput: (name, placeholder, description, label)->
		label = name if not label?
		$('<div class="form-group group-' + name + '">')
		.append($("<label>").text(label).addClass("col-sm-2 control-label"))
		.append($("<div>").addClass("col-sm-10")
			.append($("<input>").attr("name", name).addClass("form-control").attr("type", "text").attr("placeholder",
					placeholder))
			.append($("<small>").addClass("col-sm-12 bg-info").html(description)))

	addConfigtoMenu: (config) ->
		pumps = ConfigHelper.getInstance().getPumpCount(config)
		recipesCount = ConfigHelper.getInstance().getRecipesCount(config)
		recipes = ConfigHelper.getInstance().getRecipes(config)
		recipeList = $("<ul>").addClass("availableRecipes")
		addRecipeTolist = (recipe, key, list) ->
			item = $("<li>").text(recipe.recipename).data(recipe).attr("id", key);
			item.prepend($("<div>").addClass("glyphicon glyphicon-glass"))
			list.append(item)

		addRecipeTolist recipes[key], key, recipeList for key of recipes

		link = $("<a>").text(config.configname or "No Name Given").append($("<small>").text("Liquids: #{pumps} | Recipes: #{recipesCount}"));
		row = $("<li>").addClass("configuration").attr("id", config.uuid).append(link)
		row.append(recipeList)  if recipesCount != 0
		row.append($("<button>add Cocktail</button>").addClass("btn btn-xs addRecipe"))
		.data("config", config)
		link.click ()=>
			return if UnsavedHelper.getInstance().denieIfUnsaved(this)
			$(".configuration").removeClass("active")
			row.addClass("active")
			@clearConfig()
			@loadConfig(config)
		$("#cocktailconfigs").append(row)

	addPump: (pumpdata) ->
		uuid = pumpdata.uuid
		selector = $(".pumplist")
		item = $("<li>").addClass("well bg-info ")
		.append($("<div>").html("&times;").addClass("removePump").click(()->
				UnsavedHelper.getInstance().setUnsaved()
				$(@).parent().remove()))
		.append($("<label>").text("Name"))
		.append($("<input>").attr("name", "#{uuid}[name]").addClass("form-control").val(pumpdata.name).attr("placeholder",
				"e.g. Pump1337 or Vodka"))
		.append($("<label>").text("startUrl").addClass("indentedlabel"))
		.append($("<input>").attr("name",
				"#{uuid}[startUrl]").addClass("form-control indentedinput ").val(pumpdata.startUrl).attr("placeholder",
				"e.g. http://pump1337/start"))
		.append($("<label>").text("stopUrl").addClass("indentedlabel"))
		.append($("<input>").attr("name",
				"#{uuid}[stopUrl]").addClass("form-control indentedinput").val(pumpdata.stopUrl).attr("placeholder",
				"e.g. http://pump1337/stop"))
		selector.prepend(item)


	getPumpCount: ()->
		@config.pumps.length


