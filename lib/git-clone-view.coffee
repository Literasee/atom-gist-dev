fs = require 'fs'
path = require 'path'
child_process = require 'child_process'
expandHomeDir = require 'expand-home-dir'
{CompositeDisposable, BufferedProcess} = require 'atom'
{View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable, BufferedProcess} = require 'atom'

# parse out repo name from url
get_repo_name = require './get-repo-name'

module.exports =
  class GitCloneView extends View

    constructor: (@loadingModalPanel) ->
      super()

    @content: ->
      @div class: 'git-clone-input', =>
          @div 'Enter a url to `git clone` ex: https://gist.github.com/06a2cc498a33d5144d70.git'
          @subview 'urlbar', new TextEditorView(mini: true)
          @button 'Clone', {outlet: 'submitButton'}
          @button 'Cancel', {outlet: 'cancelButton'}

    initialize: ->
      @.on 'keydown', @handleKeyPress
      @submitButton.on 'click', @doClone
      @cancelButton.on 'click', @doCancel

    focus: ->
      @urlbar.focus()

    clear: ->
      @urlbar.setText ''

    handleKeyPress: (e) =>
      if e.keyCode == 13 then @doClone() # enter
      if e.keyCode == 27 then @doCancel() # escape

    doCancel: =>
      @modal.hide()

    doClone: =>
      @loadingModalPanel.show()

      # git url to clone from
      repo_url = @.urlbar.getModel().getText()

      # do clone
      target_directory = expandHomeDir(atom.config.get('atom-gist-dev.target_directory') || '/tmp')
      # user inputted
      # pull out the repo name from the uri
      repo_name = get_repo_name(repo_url)
      # get the full path to save the repo to
      full_path = path.join(target_directory, repo_name)

      if fs.existsSync(full_path)
        atom.open(pathsToOpen: [full_path], newWindow: true)
        @loadingModalPanel.hide()
        return

      @clone_repo(repo_url, full_path, (err, loc) =>
        unless err
          atom.open(pathsToOpen: [loc], newWindow: true)

        # close loading view
        @loadingModalPanel.hide()
      )
      @clear()
      @.parent().hide()

    clone_repo: (repo_url, full_path, callback) =>
      clone_stderr = ""

      command = 'git'
      args = ['clone', repo_url, full_path]
      stderr = (output) -> clone_stderr = output

      exit = (code) ->
        # pass back code to check if error & full path
        callback(code, full_path)

        unless code == 0
          alert("Exit #{code}. stderr: #{clone_stderr}")

      # clone that ish
      git_clone = new BufferedProcess({command, args, stderr, exit})
