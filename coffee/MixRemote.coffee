class MixRemote
	instance = null

	###loadedConfig = null###
	@getInstance: () ->
		instance ?= new MixRemote()
	loadConfigs: (callback) ->
		loadObject =
			cache: false
			url: "/service.php?mode=get"
			success: (json)->
				$("#configurations").text("")
				#loadedConfig = (JSON.parse(cfg) for cfg in json)
				MixRemote.getInstance().addConfigtoMenu JSON.parse(cfg) for cfg in json
			dataType: "json"
		$.ajax loadObject;

	addConfigtoMenu: (cfg) ->
		i = $("<li>").html("<h1>#{cfg.configname}</h1>").attr("id", cfg.uuid).addClass("configuration").data(cfg)
		recipeList = $("<ul>");
		addRecipeTolist = (recipe, key, list) ->
			item = $("<li>").append($("<h4>").text(recipe.recipename).click () ->
				MixRemote.getInstance().showRecipe(key)).data(recipe).attr("id", key);
			item.prepend($("<div>").addClass("glyphicon glyphicon-glass"))
			item.append(MixRemote.getInstance().getRecipeRunner(recipe, cfg))
			list.append(item)
		recipes = ConfigHelper.getInstance().getRecipes(cfg)
		addRecipeTolist recipes[key], key, recipeList for key of recipes
		i.append recipeList
		onclickfunc = () ->
			MixRemote.getInstance().configSelect(cfg.uuid)
		i.click(onclickfunc)
		$("#configurations").append(i)

	showRecipe: (uuid) ->
		$(".before").slideUp()
		$(".during").slideUp()
		$(".after").slideUp()
		$("##{uuid} .before").slideDown()
		$("##{uuid} .during").slideDown()



	configSelect: (uuid) ->
		$("body").addClass("selected");
		$("#" + uuid).addClass("selected");


	getMixture: (pumps, ingredients) ->
		list = $("<ul>").addClass("mixture");
		usedPumpIds = [];
		cliters = {};
		return list if not ingredients?
		collectUsedPumIds = (ingredient, usedPumpIds, cliters) ->
			usedPumpIds.push(ingredient.uuid)
			cliters[ingredient.uuid] = ingredient.cl
		collectUsedPumIds ingredient, usedPumpIds, cliters for ingredient in ingredients
		addRow = (pump, list)->
			isinarray = ( $.inArray(pump.uuid, usedPumpIds) > -1)
			if isinarray
				list.append($("<li>").text("#{pump.name} #{cliters[pump.uuid]} cl").addClass(pump.uuid).data(pump).data("cl",
					cliters[pump.uuid]))
		addRow p, list for p in pumps
		return list

	startBtnClick: () ->
		program = ($(item).data() for item in $(@).parent().find(".mixture li"))
		miliSecondsPerCl = $(".configuration.selected").data("miliSecondsPerCl");
		play = (prog, step) ->
			curr = prog[step]
			currName = prog[step].name
			currUUID = prog[step].uuid
			currCl = prog[step].cl
			currFillDuration = currCl * miliSecondsPerCl
			currStartUrl = prog[step].startUrl
			currStopUrl = prog[step].stopUrl
			###console.log "fill #{currName} #{currCl} cl will need #{currFillDuration}ms"###
			jQuery.ajax currStartUrl,
				complete: ()->
					$(".#{currUUID}").addClass("running")
					stopAndStartnext = ()=>
						jQuery.ajax currStopUrl,
							complete: ()->
								$("[class^=pump-]").removeClass("running")
								play program, step + 1 if program[step + 1]
								return
					setTimeout stopAndStartnext, currFillDuration
					return


		play program, 0



	getRecipeRunner: (rec, cfg) ->
		list = $("<ul>")

		list.append($("<li>").text(rec.beforetext).addClass("before"));
		list.append($("<li>").addClass("playerRow during").append(MixRemote.getInstance().getMixture(cfg.pumps,
			rec.ingredientlist)).prepend($("<button>").text("Start Mixing").addClass("btn").click(MixRemote.getInstance().startBtnClick)));
		list.append($("<li>").text(rec.aftertext).addClass("after"));
		list



