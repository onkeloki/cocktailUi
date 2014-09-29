class ConfigHelper
	instance = null
	@getInstance: () ->
		instance ?= new ConfigHelper()
	getPumpCount: (cfg)->
		return cfg.pumps.length if cfg.pumps?
		0
	getRecipesCount: (cfg) ->
		(k for own k of cfg.recipes).length

	getRecipes: (cfg) ->
		return {} if not cfg.recipes
		cfg.recipes

	getPumps: (cfg) ->
		return [] if not cfg.pumps?
		cfg.pumps
