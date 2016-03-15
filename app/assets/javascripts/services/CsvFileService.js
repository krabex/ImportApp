ImportApp.service('CsvFileService', ['$http', 'Upload', function($http, Upload) {

  this.uploadFile = function(file) {
    return Upload.upload({ 
      url: '/parsing_files', 
      file: file
    });
  }

  this.exportFile = function(filter) {
    return $http({
      url: '/downloads/export_csv/' + filter,
      method: 'POST'
    });
  }

}]);

