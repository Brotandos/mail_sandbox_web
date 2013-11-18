angular.module('app.modules.mail_applications.controllers')
  .controller 'ShowMailApplicationController',
    ($scope, mailApplications, mailMessages, Faye, railsRoutesHelper, $state, $stateParams, $sce, _) ->

      mailApplications.get($stateParams.id).then (mailApp)->
        $scope.mailApp = mailApp

      $scope.$on('filter_form:submit', (event, filterParams) ->
        resetPaginationParams()

        $scope.filterParams = filterParams

        $scope.loadMore()
        )

      $scope.$on('filter_form:cancel', (event) ->
        resetPaginationParams()

        $scope.filterParams = {}

        $scope.loadMore()
        )
      #
      # Faye.subscribe App.config.faye_channel_message_new, (message) ->
      #   if $scope.mailApp.name == message.mail_application

      #     $scope.mailAppMessages.splice(0, 0, message)
      #     $scope.mailAppMessages.pop()
      #     $scope.$apply()

      resetPaginationParams = ->
        $scope.mailAppMessages = []
        $scope.current_page = 1
        $scope.total_pages = 1
        $scope.pages_loaded = []

      $scope.masterChbox = false

      $scope.isChecked = (message) ->
        message.isChecked

      $scope.checkAll = ->
        _.map($scope.mailAppMessages, (message) ->
          message.isChecked = true
        )

      $scope.unCheckAll = ->
        _.map($scope.mailAppMessages, (message) ->
          message.isChecked = false
        )

      $scope.onMasterChboxChange = ->
        if $scope.masterChbox
          $scope.checkAll()
        else
          $scope.unCheckAll()

      checkedMessagesIds = ->
        $scope.checkedMessages = _.filter($scope.mailAppMessages, (message) ->
          message.isChecked
        )
        _.pluck($scope.checkedMessages, 'id')

      $scope.markReadCheckedMessages = ->
        #TODO better solution
        console.log $scope.checkedMessages

        checkedIds = checkedMessagesIds()
        console.log $scope.checkedMessages

        _.map($scope.checkedMessages, (message) ->
          message.state = 'read'
        )

        mailMessages.batchUpdate({
          mail_application_id: $stateParams.id,
          ids: checkedMessagesIds,
          mail_message: { state_event: 'mark_read' }
        })

      $scope.deleteCheckedMessages = ->
        #TODO pagination
        checkedIds = checkedMessagesIds()
        console.log checkedIds
        $scope.mailAppMessages = _.reject($scope.mailAppMessages, (message) ->
          message.isChecked == true
        )
        mailMessages.batchUpdate({
          mail_application_id: $stateParams.id,
          ids: checkedIds,
          mail_message: { state_event: 'mark_as_deleted' }
        })


      resetPaginationParams()

      $scope.editMailApp = (mailApp) ->
        $state.transitionTo 'edit_mail_application', { id: mailApp.id }

      $scope.loadMore = ->
        if $scope.total_pages >= $scope.current_page
          if !_.include($scope.pages_loaded, $scope.current_page)

            params = { page: $scope.current_page }
            $scope.messagesLoading = true

            mailMessages.query(_.extend(params, $scope.filterParams), { mail_application_id: $stateParams.id }).then (results) ->
              $scope.mailAppMessages = $scope.mailAppMessages.concat(results.items)

              $scope.total_pages = results.meta.total_pages

              $scope.current_page++

              $scope.messagesLoading = false

          $scope.pages_loaded.push($scope.current_page)

      $scope.loadMore()

      $scope.showMailAppMessage = (message) ->
        $scope.resourceMessage = message

        $scope.resourceMessage.without_bootstrap_path ||= railsRoutesHelper.mail_message_without_bootstrap_path($scope.mailApp.id, message.id)

        if $scope.resourceMessage.state == 'unread'
          $scope.resourceMessage.state = 'read'

          params = { id: message.id, mail_application_id: $stateParams.id, state_event: 'mark_read' }
          new mailMessages(params).update()

        $scope.resourceMessageBody = $sce.trustAsHtml(message.body)

      $scope.showMailAppMessageRaw = (message) ->
        $state.transitionTo 'raw_mail_message', { id: message.id, mail_application_id: $stateParams.id }
      $scope.showMailAppMessageWithoutBootstrap = (message) ->
        $state.transitionTo 'without_bootstrap_mail_message', { id: message.id, mail_application_id: $stateParams.id }