Package.describe({
  name: 'cooperm:sidecomments',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'Add side comments to any page of your meteor app',
  // URL to the Git repository containing the source code for this package.
  git: '',
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
    'jquery'
  ], 'client');

  // FILES FOR CLIENT ONLY
  api.addFiles(
    'sidecomments.html', 'client');

  // EXPORTS
  api.export('SideCommentsInit', 'client');

  // FILES FOR SERVER AND CLIENT
  api.addFiles([
    'sidecomments.coffee'
  ], both);


  // PACKAGES FOR SERVER AND CLIENT
  api.use([
    'coffeescript',
    'mongo'
  ], both);



  // STATIC ASSETS FOR CLIENT
  api.addFiles([
    'public/default_avatar_64.png'
  ], 'client', { isAsset: true });


});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('cooperm:meteor-sidecomments');
  api.addFiles('cooperm:meteor-sidecomments-tests.js');
});
