ImportApp.controller('ImportAppCtrl', function($scope, $http, $interval, Upload) {

  $scope.fileId;
  $scope.filter = "";

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
          
          $scope.dispatcher = new WebSocketRails('localhost:3000/websocket');
          $scope.channel = $scope.dispatcher.subscribe('parsing_file');

          $scope.channel.bind('parsing_status', $scope.onParsingStatusReceived);
        }
      });
    }
  }

  $scope.onParsingStatusReceived = function(data) {
      $scope.fileStats = data;
      if(data.state == "parsed") {
        $scope.fileProcessing = false;
        $scope.loadCompanies();
      }
      $scope.$apply();
      console.log($scope.fileStats);
  }

  $scope.loadCompanies = function() {
    $http({
      url: '/companies',
      method: 'GET'
    }).success(function(response) {
      $scope.companies = response.companies;
      angular.forEach($scope.companies, function(v,k) {
        v.stats = response.stats[k];
      });
      console.log($scope.companies);
    });
  }

  $scope.meetsFilterCriteria = function(operation) {
    return $scope.filter == "" ||
           $scope.filter == operation.invoice_num ||
           $scope.filter == operation.reporter ||
           $scope.filter == operation.status ||
           $scope.filter == operation.kind;
  }

  $scope.export = function() {
    $scope.downloadState = { "state": "Sending request..." };

    $http({
      url: '/downloads/export_csv/' + $scope.filter,
      method: 'POST'
    }).success(function(response) {
      $scope.exportFileId = response.id;
      $scope.dispatcher = new WebSocketRails('localhost:3000/websocket');
      $scope.channel = $scope.dispatcher.subscribe('exporting_file');

      $scope.channel.bind('exporting_status', $scope.onExportingStatusReceived);
    });
  }

  $scope.onExportingStatusReceived = function(data) {
    $scope.downloadState = data;
    console.log($scope.downloadState);
    $scope.$apply();
  }

});
