ImportApp.controller('ImportAppCtrl', function($scope, $http, $interval, Upload) {

  var CHECK_PARSING_PROGRESS_INTERVAL_IN_MS = 2000;
  $scope.fileId;
  $scope.inverval

  $scope.uploadFile = function(file) {
    if(file) {
      $scope.fileProcessing = true;
      $scope.fileStats = {"state": "uploading file"}
      Upload.upload({ 
        url: '/parsing_files', 
        file: file,
      }).success(function(response) {
        if(response.succeed) {
          $scope.fileId = response.id;
          $scope.interval = $interval(
            $scope.loadParsingProgress,
            CHECK_PARSING_PROGRESS_INTERVAL_IN_MS
          );
        }
      });
    }
  }

  $scope.loadParsingProgress = function() {
    $http({
      url: '/parsing_files/' + $scope.fileId + '/state/',
      method: 'GET'
    }).success(function(response) {
      $scope.fileStats = response;
      if(response.state == "parsed") {
        $interval.cancel($scope.interval);
        $scope.fileProcessing = false;
        $scope.loadCompanies();
      }
      console.log(response);
    });
  }

  $scope.loadCompanies = function() {
    $http({
      url: '/companies',
      method: 'GET'
    }).success(function(response) {
      $scope.companies = response;
      console.log(response);
    });
  }

});
