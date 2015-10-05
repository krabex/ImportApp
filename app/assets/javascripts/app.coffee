@ImportApp = angular
  .module('ImportApp', ['templates', 'ngFileUpload', 'ui.bootstrap'])
  .config(($httpProvider) -> 
    $httpProvider.defaults.headers.common['X-Requested-With'] = 
      'AngularXMLHttpRequest';
  )
