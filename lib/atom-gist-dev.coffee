GitCloneView = require './git-clone-view'
GitCloneLoadingView = require './git-clone-loading-view'
get_repo_name = require './get-repo-name'
{CompositeDisposable, BufferedProcess} = require 'atom'
git = require 'gity'
gitAuto = require 'git-auto'

path = require 'path'
child_process = require 'child_process'

module.exports = AtomGistDev =
  gitCloneModal: null
  subscriptions: null

  # package config options
  config:
    github_username:
      type: 'string'
      default: ''
    target_directory: # where repos will be cloned
      type: 'string'
      default: '/tmp'

  # package name
  name: 'atom-gist-dev'

  # register commands that this package supports
  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gist-dev:clone': => @clone()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gist-dev:pull': => @pull()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gist-dev:save': => @save()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gist-dev:save-share': => @save(true)

  # destroy views and subscriptions
  deactivate: ->
    @gitCloneModal.destroy()
    @subscriptions.dispose()

  # clone Gist/repo
  clone: ->
    if !@gitCloneLoadingView
      @gitCloneLoadingView = new GitCloneLoadingView()
      @gitCloneLoadingModal = atom.workspace.addModalPanel(item: @gitCloneLoadingView, visible: false)
      @gitCloneView = new GitCloneView(@gitCloneLoadingModal)
      @gitCloneModal = atom.workspace.addModalPanel(item: @gitCloneView, visible: false)
      @gitCloneView.modal = @gitCloneModal

    if @gitCloneModal.isVisible()
      @gitCloneModal.hide()
    else
      @gitCloneModal.show()
      @gitCloneView.focus()

  pull: ->
    gitOpts = {base: atom.project.getDirectories()[0].path}

    git(gitOpts)
      .status()
      .run((err, res) ->
        if (err) then alert('Error checking status: ' + err)

        edits = 0
        edits += v.length for k, v of res
        if (!edits) # if status is clean, pull
          git(gitOpts)
            .pull()
            .run((err, res) ->
              if (err) then alert('Error fetching changes: ' + err)
              console.log res
            )
        else
          alert('You have unsaved changes in your project. Save Changes and try again.')
      )

  save: (push) ->
    gitAuto({
      base:  atom.project.getDirectories()[0].path
      group: true
      push:  push
    })

    if push
      Promise.all(atom.project.getDirectories().map(atom.project.repositoryForDirectory.bind(atom.project))).then (repo) ->
        repoName = get_repo_name(repo[0].getOriginURL())
        github_username = atom.config.get('atom-gist-dev.github_username')
        if github_username then github_username += '/'
        atom.clipboard.write('https://nciea-gist-viewer.herokuapp.com/' + github_username + repoName)
        alert('nciea-gist-viewer link has been copied to your clipboard!')
