class Service
	instance = null
	@getInstance: () ->
		instance ?= new Service()
	###
  delete function
	###
	deleteConfigById: (id) ->
		loadObject =
			cache: false
			url: "/service.php?mode=delete&" + Date.now()
			type: "POST"
			data:
				data: id
			success: () ->
				showIndexAfterLoad = () ->
					CocktailUi.getInstance().showArea(CocktailUi.AREA_INDEX)
				Service.getInstance().loadConfigs(showIndexAfterLoad)
		$.ajax loadObject

	duplicateCurrentConfig: () ->
		cfg = CocktailUi.getInstance().getConfigFromForm();
		cfg.uuid = CocktailUi.getInstance().getUniQueId("config-")
		cfg.configname = cfg.configname + " copy"
		loadAfterSafe = () ->
			selectSavedConfigAfterSave = () ->
				uuid = cfg.uuid
				FrontendHelper.getInstance().selectConfigFroMenu(uuid)
			instance.loadConfigs(selectSavedConfigAfterSave);
		instance.saveConfig(cfg, loadAfterSafe)


	deleteCurrentConfig: ()->
		cfg = CocktailUi.getInstance().getConfigFromForm();
		Service.getInstance().deleteConfigById(cfg.uuid)

	###
		save functions
	###
	saveCurrentConfig: () ->
		cfg = CocktailUi.getInstance().getConfigFromForm()
		loadAfterSafe = () ->
			selectSavedConfigAfterSave = () ->
				alert "Saved"
				uuid = cfg.uuid
				FrontendHelper.getInstance().selectConfigFroMenu(uuid)
			instance.loadConfigs(selectSavedConfigAfterSave);
		instance.saveConfig(cfg, loadAfterSafe)

	saveConfig: (cfg, callback) ->
		saveCurrentConfig = cfg.uuid
		loadObject =
			cache: false
			url: "/service.php?mode=save&" + Date.now()
			type: "POST"
			data: cfg
			success: () =>
				callback() if callback?
		$.ajax loadObject

	loadConfigs: (callback) ->
		loadObject =
			cache: false
			url: "/service.php?mode=get"
			success: (json)->
				UnsavedHelper.getInstance().setSaved()
				$("#cocktailconfigs").text("")
				CocktailUi.getInstance().addConfigtoMenu JSON.parse(cfg) for cfg in json
				callback() if callback?
			dataType: "json"
		$.ajax loadObject;
