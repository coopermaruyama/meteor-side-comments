@SideComment = new Mongo.Collection 'side_comments'

SideComment.allow
  insert: (userId, doc) ->
    !!userId
  update: (userId, doc, fields, modifier) ->
    doc.comment.authorId == userId
  remove: (userId, doc) ->
    doc.comment.authorId == userId


if Meteor.isServer
  Meteor.publish 'sideCommentsForPath', (path) ->
    return SideComment.find({path: path})

if Meteor.isClient
  @test = []
  settings = Meteor.settings?.public?.sideComments
  Template.SideCommentsInit.rendered = ->
    if $('#commentable-area')?
      # init
      SideComments = require 'side-comments'
      the_path = window.location.pathname

      # decorate areas
      ($ '#commentable-area p').each (i,v) ->
        unless $(this).parents('.commentable-section').length > 0
          ($ this).addClass("commentable-section").attr "data-section-id", i

      # setup user info
      if Meteor.user()
        name = null
        avatar = null
        user = Meteor.user()
        avatar_default = settings.defaultAvatar || "/packages/cooperm_sidecomments/public/default_avatar_64.png"
        if user.services?.google?
           name = user.services.google.name
           avatar = user.services.google.picture
        else
          name = user.username
          avatar = avatar_default
        if name?
          commentUser =
            name: name
            avatarUrl: avatar
            id: user._id
      else
        commentUser =
          name: 'Login to comment'
          avatarUrl: avatar_default
          id: 0

      # load existing comments
      Meteor.subscribe 'sideCommentsForPath', the_path, ->
        window.existingComments = []
        SideComment.find({path: the_path}).forEach (comment) ->
          comment.comment.id = comment._id
          sec = _(existingComments).findWhere({sectionId: comment.sectionId.toString()})
          if sec
            sec.comments.push comment.comment
          else
            existingComments.push
              sectionId: comment.sectionId.toString()
              comments: [comment.comment]
        # add side comments
        window.sideComments = new SideComments '#commentable-area', commentUser, existingComments
        # side comment events
        sideComments.on 'commentPosted', (comment) ->
          if Meteor.user()
            attrs =
              path: the_path
              sectionId: comment.sectionId
              comment:
                authorAvatarUrl: comment.authorAvatarUrl
                authorName: comment.authorName
                authorId: comment.authorId
                comment: comment.comment
            commentId = SideComment.insert attrs
            comment.id = commentId
            sideComments.insertComment comment
          else
            comment.id = -1
            sideComments.insertComment
              sectionId: comment.sectionId
              authorName: comment.authorName
              comment: 'Please login to post comments'
        sideComments.on 'commentDeleted', (comment) ->
          if Meteor.user()
            SideComment.destroyAll comment.id
            sideComments.removeComment comment.sectionId, comment.id
