GitCloneView = require './git-clone-view'
GitCloneLoadingView = require './git-clone-loading-view'
{CompositeDisposable, BufferedProcess} = require 'atom'
git = require 'git-auto'

path = require 'path'
child_process = require 'child_process'

module.exports = AtomGistDev =
  gitCloneModal: null
  subscriptions: null

  # package config options
  config:
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

  save: (push) ->
    p = atom.project.getDirectories()[0].path
    git({base: p, group: true, push: push})
