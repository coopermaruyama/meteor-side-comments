Package.describe({
  name: 'cooperm:side-comments',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: 'Add side comments to any page of your meteor app',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/coopermaruyama/meteor-side-comments',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  var both = ['client', 'server'];
  api.versionsFrom('1.0.3.2');

  // PACKAGES FOR CLIENT ONLY
  api.use([
    'templating',
    'underscore',
    'jquery',
    'accounts-base',
    'reactive-var'
  ], 'client');

  // FILES FOR CLIENT ONLY
  api.addFiles([
    'sidecomments.html',
    'client/compatibility/md5.min.js',
    'client/compatibility/side-comments.js',
    'client/compatibility/side-comments.css',
    'client/compatibility/side-comments.theme.min.css'
  ], 'client');


  // FILES FOR SERVER AND CLIENT
  api.addFiles([
    'sidecomments.coffee'
  ], both);


  // PACKAGES FOR SERVER AND CLIENT
  api.use([
    'coffeescript',
    'mongo'
  ], both);


  // EXPORTS
  api.export([
    'SideCommentsInit',
    'require',
    'SideComments',
    'SideComment'
  ], ['client', 'web.browser']);


});

Package.onTest(function(api) {
  api.use('tinytest');
  // api.use('cooperm:meteor-sidecomments');
  api.addFiles('cooperm:meteor-sidecomments-tests.js');
});
