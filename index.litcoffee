VOSCO
=====

Dependencies
------------

    path   = require "path"
    {exec} = require "child_process"

Constructor
-----------

    VOSCO = (@path, @options) ->
      @env = @_getEnvironmentVariables()
      # TODO validate options

Setup
-----

    VOSCO::install = (callback) ->
      await @createRepository defer()
      await @createSnapshot 'Install VOSCO', defer()
      callback null

Repository
----------

    VOSCO::getRepositoryPath = ->
      path.resolve @path, '.vosco'

    VOSCO::createRepository = (callback) ->
      await @_runGitCommand "init --template #{@_getTemplateDir()}", defer()
      callback null

    VOSCO::getHistory = (callback) ->
      command = "log --pretty=format:#{@_getLogFormat()} --all"
      await @_runGitCommand command, defer(error, stdout, stderr)
      callback null, @_parseLogOutput(stdout)

Information
-----------

    VOSCO::getStatus = (callback) ->
      # TODO

    VOSCO::getBlameInfo = (paths, callback) ->
      await @_runGitCommand "blame -t -l #{path}", defer(error, stdout, stderr)
      callback null, @_parseBlameOutput(stdout)

Snapshot
--------

    VOSCO::createSnapshot = (message, callback) ->
      await @_runGitCommand "add --all .", defer()
      await @_runGitCommand "commit -m \"#{message}\"", defer()
      callback null

    VOSCO::rollbackToSnapshot = (commit, callback) ->
      await @_runGitCommand "clean -f", defer()
      await @_runGitCommand "reset --hard \"#{commit}\"", defer()
      callback null

Branch
------

    VOSCO::createBranch = (branch, callback) ->
      await @_runGitCommand "branch \"#{branch}\"", defer()
      await @selectBranch branch, defer()
      callback null

    VOSCO::selectBranch = (branch, callback) ->
      await @_runGitCommand "clean -f", defer()
      await @_runGitCommand "checkout \"#{branch}\"", defer()
      callback null

    VOSCO::deleteBranch = (branch, callback) ->
      await @_runGitCommand "branch -D \"#{branch}\"", defer()
      callback null

Helpers
-------

    VOSCO::_getEnvironmentVariables = ->
      GIT_DIR: @getRepositoryPath()
      GIT_WORK_TREE: @path
      GIT_AUTHOR_NAME: @options.author_name
      GIT_AUTHOR_EMAIL: @options.author_email
      GIT_COMMITTER_NAME: @options.author_name
      GIT_COMMITTER_EMAIL: @options.author_email
      VOSCO_APP_DIR: __dirname

    VOSCO::_getTemplatePath = ->
      path.resolve __dirname, 'template'

    VOSCO::_getLogFormat = ->
      '\'{"commit": "%H", "author": "%an", "email": "%ae", "date": "%ad", "message": "%s"}\''

    VOSCO::_runGitCommand = (command, callback) ->
      options = {cwd: @path, env: @_getEnvironmentVariables()}
      exec "git #{command}", options, callback

Helpers (parsers)
-----------------

    VOSCO::_parseLogOutput = (stdout) ->
      lines = stdout.split "\n"
      lines.map (line) -> JSON.parse(line)

    VOSCO::_parseBlameOutput = (stdout) ->
      lines = stdout.split "\n"
      lines.map (line) ->
        matches = regex.exec line
        result =
          commit: matches[1]
          author: matches[2]
          time: matches[3]
          line: matches[4]
          content: matches[5]

Export Module
-------------

    module.exports = VOSCO