@ImportApp = angular
  .module('ImportApp', ['templates', 'ngFileUpload'])
  .config(($httpProvider) -> 
    $httpProvider.defaults.headers.common['X-Requested-With'] = 
      'AngularXMLHttpRequest';
  )
