angular.module('app').config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider.otherwise "/"
  $locationProvider.html5Mode(true)

  $stateProvider
    .state('mail_applications',
      url: "/mail_applications"
      templateUrl: RouterHelper.templateUrl('mail_applications/index')
      controller: 'ListMailApplicationsController'
    )
    .state('new_mail_application',
      url: '/mail_applications/new'
      templateUrl: RouterHelper.templateUrl('mail_applications/new')
      controller: 'NewMailApplicationController'
    )
    .state('edit_mail_application',
      url: '/mail_applications/edit'
      templateUrl: RouterHelper.templateUrl('mail_applications/edit')
      controller: 'EditMailApplicationController'
    )
    .state('show_mail_application',
      url: '/mail_applications/{id}'
      templateUrl: RouterHelper.templateUrl('mail_applications/show')
      controller: 'ShowMailApplicationController'
    )
