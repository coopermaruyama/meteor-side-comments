SideComment = new Mongo.Collection 'side_comments'

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
  # create user object for Side Comments
  # returns object
  # -------------------------------------
  getCommentUser = () ->
    if Meteor.user()
      name = null
      avatar = null
      user = Meteor.user()
      avatar_default = settings.defaultAvatar if settings?.defaultAvatar
      name = user.username if user.username?

      if (_services = user.services)?
        if (_google = _services.google)?
          name = _google.name if _google.name?
          avatar = _google.picture if _google.picture?
        if (_fb = _services.facebook)?
          name = _fb.name if _fb.name?
          avatar = "//graph.facebook.com/#{fb.id}/picture" if _fb.id?
        if (_twitter = _services.twitter)?
          name = _twitter.screenName if _twitter.screenName?
          avatar = _twitter.profile_image_url if _twitter.profile_image_url?
      if (_profile = user.profile)?
        name = _profile.name if _profile.name?
        avatar = _profile.avatar if _profile.avatar?
      name ?= user.emails[0].address
      avatar ?= "//www.gravatar.com/avatar/#{md5(user.emails[0].address)}.jpg"
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
    return commentUser

  # init vars
  # ----------
  @test = []
  settings = Meteor.settings?.public?.sideComments
  Meteor.startup ->
    # render
    # -------
    Template.SideCommentsInit.rendered = ->
      tpl = @view.parentView.templateInstance()
      `SideComments = require('side-comments');`
      $ ->
        if $('#commentable-area')?
          the_path = window.location.pathname

          # decorate areas
          ($ '#commentable-area p').each (i,v) ->
            unless $(this).parents('.commentable-section').length > 0
              ($ this).addClass("commentable-section").attr "data-section-id", i

          # setup user info
          commentUser = getCommentUser()

          # load existing comments
          tpl.subscribe 'sideCommentsForPath', the_path, ->
            tpl.existingComments = new ReactiveVar([])
            SideComment.find({path: the_path}).forEach (comment) ->
              comment.comment.id = comment._id
              sec = _(tpl.existingComments.get()).findWhere({sectionId: comment.sectionId.toString()})
              if sec
                sec.comments.push comment.comment
              else
                tpl.existingComments.get().push
                  sectionId: comment.sectionId.toString()
                  comments: [comment.comment]
            #
            # add side comments
            unless tpl.side_comments?
              tpl.side_comments = new SideComments '#commentable-area', commentUser, tpl.existingComments.get()


              # side comment events
              tpl.side_comments.on 'commentPosted', (comment) ->
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
                  tpl.side_comments.insertComment comment
                else
                  comment.id = -1
                  tpl.side_comments.insertComment
                    sectionId: comment.sectionId
                    authorName: comment.authorName
                    comment: 'Please login to post comments'
              tpl.side_comments.on 'commentDeleted', (comment) ->
                if Meteor.user()
                  SideComment.destroyAll comment.id
                  tpl.side_comments.removeComment comment.sectionId, comment.id
            #/endunless

            # autoRun: update current user when logging in
            tpl.autorun ->
              unless Meteor.loggingIn()
                if Meteor.user()
                  tpl.side_comments.setCurrentUser getCommentUser()
          #/endcallback (sideCommentsForPath.subscribe)
