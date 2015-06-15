GitCloneView = require './git-clone-view'
GitCloneLoadingView = require './git-clone-loading-view'
{CompositeDisposable, BufferedProcess} = require 'atom'

path = require 'path'
child_process = require 'child_process'

module.exports = AtomGistDev =
  atomGistDevView: null
  modalPanel: null
  subscriptions: null

  config:
    target_directory:
      type: 'string'
      default: '/tmp'

  name: 'atom-gist-dev'

  activate: (state) ->
    @loadingView = new GitCloneLoadingView()
    @loadingModalPanel = atom.workspace.addModalPanel(item: @loadingView, visible: false)
    @gitCloneView = new GitCloneView(state.gitCloneViewState, @loadingModalPanel)
    @modalPanel = atom.workspace.addModalPanel(item: @gitCloneView, visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-gist-dev:clone': => @clone()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomGistDevView.destroy()

  serialize: ->
    atomGistDevViewState: @atomGistDevView.serialize()

  clone: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
      @gitCloneView.focus()
