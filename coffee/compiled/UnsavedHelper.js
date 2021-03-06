// Generated by CoffeeScript 1.8.0
var UnsavedHelper;

UnsavedHelper = (function() {
  var instance;

  function UnsavedHelper() {}

  instance = null;

  UnsavedHelper.getInstance = function() {
    return instance != null ? instance : instance = new UnsavedHelper();
  };

  UnsavedHelper.prototype.denieIfUnsaved = function(promoter) {
    var isunsaved;
    isunsaved = $("body").hasClass("unsaved");
    if (isunsaved) {
      UnsavedHelper.getInstance().showDialog(promoter);
    }
    return isunsaved;
  };

  UnsavedHelper.prototype.showDialog = function(promoter) {
    var des;
    des = confirm("unsaved stuff get lost, continue?");
    if (des) {
      UnsavedHelper.getInstance().setSaved();
    }
    if (des) {
      return $(promoter).click();
    }
  };

  UnsavedHelper.prototype.setUnsaved = function() {
    return $("body").addClass("unsaved");
  };

  UnsavedHelper.prototype.setSaved = function() {
    return $("body").removeClass("unsaved");
  };

  return UnsavedHelper;

})();

$().ready(function() {
  $("body").on("click", ".addPump", function() {
    return UnsavedHelper.getInstance().setUnsaved();
  });
  $("body").on("keyup", "#config input", function() {
    return UnsavedHelper.getInstance().setUnsaved();
  });
  $("body").on("keyup", "#recipe input", function() {
    return UnsavedHelper.getInstance().setUnsaved();
  });
  return $("body").on("keyup", "#recipe select", function() {
    return UnsavedHelper.getInstance().setUnsaved();
  });
});
