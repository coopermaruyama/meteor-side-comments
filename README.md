# Meteor Side Comments

Easily add side-comments.js to any page on your site. Get it up and running
within minutes.

demo: http://sidecomments-demo.meteor.com/  
demo repo: https://github.com/coopermaruyama/meteor-sidecomments-demo

---

### Install

~~~
meteor add cooperm:side-comments
~~~


## Usage
To use, wrap the content you want to make commentable with
`<div id="commentable-area">`. Then, include our (blank) template which
initializes side commments:

~~~html
<template name="TemplateYouWantToMakeCommentable">
  <div id="commentable-area">
    <p>Your content</p>
  </div>
  {{> SideCommentsInit}}
</template>
~~~

By default all <p> elements are matched (unless it has a parent with a side comment already).You can overide the default selector in settings.json:

~~~json
{
  "public": {
    "sideComments": {
       "customSelector": "p, .custom, span.wrapMeToo"
    }
  }
}
~~~



Optionally define a default avatar in settings.json:

~~~json
{
  "public": {
    "sideComments": {
       "customSelector": "p, .custom, span.wrapMeToo",
       "defaultAvatar": "/path/to/avatar.png"
    }
  }
}
~~~

---

## How it works

Meteor side comments works by looking for any `<div>` tag with id `commentable-area`.
It then looks through its children for `<p>` tags (or whatever custom selector you defined) and uses them as sections to
turn into commentable sections.

The `{{> SideCommentsInit}}` include is just a blank template, but initializes
side comments via `Template.SideCommentsInit.rendered`.

This package does not rely on iron router. Also, pathnames are used as ID's
rather than template names since the same template could show different content
if it's pulling content from a database.
