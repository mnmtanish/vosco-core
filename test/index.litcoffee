Requirements
------------

    assert = require "assert"
    fs     = require "fs"
    path   = require "path"
    {exec} = require "child_process"
    async  = require "async"
    VOSCO  = require ".."

VOSCO
-----

    describe "VOSCO", ->

      it "should copy gitignore file to repo path", (finish) ->
        vosco = new VOSCO test_path
        vosco._copyGitignore ->
          gitignore = path.join test_path, ".gitignore"
          assert.equal true, fs.existsSync gitignore
          do finish

      it "should list all commits", (finish) ->
        vosco = new VOSCO test_path
        options = {cwd: test_path, env: vosco._getEnv()}
        run = (cmd, cb) -> exec cmd, options, (err) -> cb(err)
        async.waterfall [
          (cb) -> run "echo Hello > test.txt", cb
          (cb) -> run "git init", cb
          (cb) -> run "git add test.txt", cb
          (cb) -> run "git commit -m 'test commit'", cb
          (cb) -> vosco.log 5, cb
        ], (error, result) ->
          assert.equal true, Array.isArray result
          assert.equal 1, result.length
          assert.equal 'test commit', result[0].message
          do finish

      it "should create new commit", (finish) ->
        vosco = new VOSCO test_path
        options = {cwd: test_path, env: vosco._getEnv()}
        run = (cmd, cb) -> exec cmd, options, (err) -> cb(err)
        async.waterfall [
          (cb) -> run "echo Hello > test.txt", cb
          (cb) -> run "git init", cb
          (cb) -> vosco.commit 'test commit', (err) -> cb(err)
          (cb) -> vosco.log 5, cb
        ], (error, result) ->
          assert.equal 1, result.length
          assert.equal 'test commit', result[0].message
          do finish

      it "should initialize the repository", (finish) ->
        vosco = new VOSCO test_path
        vosco.install ->
          vosco.log 10, (error, result) ->
            assert.equal 1, result.length
            assert.equal "Initial Commit", result[0].message
            do finish

Helpers
-------

      test_path = "/tmp/test_repo"
      repo_path = "/tmp/test_repo/.vosco"

      beforeEach (done) ->
        exec "mkdir #{test_path}", done

      afterEach (done) ->
        exec "rm -rf #{test_path}", done