ImportApp.controller('ImportAppCtrl', function($scope, Upload) {

  $scope.uploadFile = function(file) {
    if(file) {
      Upload.upload({ 
        url: '/parsing_files/new', 
        file: file 
      }).success(function(response) {
        if(response.succeed) {
          console.log("succeed");
        }
      });
    }
  }

});
