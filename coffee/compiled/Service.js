// Generated by CoffeeScript 1.8.0
var Service;

Service = (function() {
  var instance;

  function Service() {}

  instance = null;

  Service.getInstance = function() {
    return instance != null ? instance : instance = new Service();
  };


  /*
   delete function
   */

  Service.prototype.deleteConfigById = function(id) {
    var loadObject;
    loadObject = {
      cache: false,
      url: "/service.php?mode=delete&" + Date.now(),
      type: "POST",
      data: {
        data: id
      },
      success: function() {
        var showIndexAfterLoad;
        showIndexAfterLoad = function() {
          return CocktailUi.getInstance().showArea(CocktailUi.AREA_INDEX);
        };
        return Service.getInstance().loadConfigs(showIndexAfterLoad);
      }
    };
    return $.ajax(loadObject);
  };

  Service.prototype.duplicateCurrentConfig = function() {
    var cfg, loadAfterSafe;
    cfg = CocktailUi.getInstance().getConfigFromForm();
    cfg.uuid = CocktailUi.getInstance().getUniQueId("config-");
    cfg.configname = cfg.configname + " copy";
    loadAfterSafe = function() {
      var selectSavedConfigAfterSave;
      selectSavedConfigAfterSave = function() {
        var uuid;
        uuid = cfg.uuid;
        return FrontendHelper.getInstance().selectConfigFroMenu(uuid);
      };
      return instance.loadConfigs(selectSavedConfigAfterSave);
    };
    return instance.saveConfig(cfg, loadAfterSafe);
  };

  Service.prototype.deleteCurrentConfig = function() {
    var cfg;
    cfg = CocktailUi.getInstance().getConfigFromForm();
    return Service.getInstance().deleteConfigById(cfg.uuid);
  };


  /*
  		save functions
   */

  Service.prototype.saveCurrentConfig = function() {
    var cfg, loadAfterSafe;
    cfg = CocktailUi.getInstance().getConfigFromForm();
    loadAfterSafe = function() {
      var selectSavedConfigAfterSave;
      selectSavedConfigAfterSave = function() {
        var uuid;
        alert("Saved");
        uuid = cfg.uuid;
        return FrontendHelper.getInstance().selectConfigFroMenu(uuid);
      };
      return instance.loadConfigs(selectSavedConfigAfterSave);
    };
    return instance.saveConfig(cfg, loadAfterSafe);
  };

  Service.prototype.saveConfig = function(cfg, callback) {
    var loadObject, saveCurrentConfig;
    saveCurrentConfig = cfg.uuid;
    loadObject = {
      cache: false,
      url: "/service.php?mode=save&" + Date.now(),
      type: "POST",
      data: cfg,
      success: (function(_this) {
        return function() {
          if (callback != null) {
            return callback();
          }
        };
      })(this)
    };
    return $.ajax(loadObject);
  };

  Service.prototype.loadConfigs = function(callback) {
    var loadObject;
    loadObject = {
      cache: false,
      url: "/service.php?mode=get",
      success: function(json) {
        var cfg, _i, _len;
        UnsavedHelper.getInstance().setSaved();
        $("#cocktailconfigs").text("");
        for (_i = 0, _len = json.length; _i < _len; _i++) {
          cfg = json[_i];
          CocktailUi.getInstance().addConfigtoMenu(JSON.parse(cfg));
        }
        if (callback != null) {
          return callback();
        }
      },
      dataType: "json"
    };
    return $.ajax(loadObject);
  };

  return Service;

})();