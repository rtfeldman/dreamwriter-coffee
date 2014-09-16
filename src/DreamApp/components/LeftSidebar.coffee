Outline   = require "./Outline.coffee"
React     = require "react"
AppAction = require "../AppAction.coffee"
DreamDoc  = require "../../DreamDoc/DreamDoc.coffee"
_         = require "lodash"

defaultNewDocHtml = require "./../defaultNewDoc.coffee"

{div, span, ul, b, li} = require "../../React/dsl.coffee"

module.exports = LeftSidebar = React.createClass
  getInitialState: -> {showOpenMenu: false}

  render: ->
    {currentDoc} = @props

    if @state.showOpenMenu
      docList = if @props.docs
        # Use the currentDoc where available, as it may have more up-to-date info.
        docsWithCurrent = _.map @props.docs, (doc) ->
          if doc.id is currentDoc.id
            currentDoc
          else
            doc

        sortedDocs = _.sortBy docsWithCurrent, (doc) => -doc.lastModified.getTime()

        (sortedDocs.map (doc) =>
          className = if doc.id is currentDoc.id
            "open-entry current"
          else
            "open-entry"

          (div {className, onClick: @getOpenDocHandler(doc)}, doc.title)
        )
      else
        (div {}, "Syncing...")

      (div {id: "left-sidebar-container", className: "sidebar", key: "left-sidebar-container"}, [
        (div {key: "left-sidebar-header", id: "left-sidebar-header", className: "sidebar-header"}, [
          (span {className: "sidebar-header-control", key: "cancel", onClick: @getOpenMenuClickHandler(false)}, ["cancel"])
        ])
        (div id: "open", [
          (React.DOM.input {id: "openFileChooser", value: "", ref: "openFileChooser", onChange: @handleFileChooserChange, type: "file", multiple: "true", accept: "text/html"})
          (div {className: "open-entry", onClick: @handleShowOpenFile}, [
            (span {}, "A ")
            (b    {}, ".html")
            (span {}, " file from your computer...")
          ])
          docList
        ])
      ])
    else if currentDoc
      (div {id: "left-sidebar-container", className: "sidebar", key: "left-sidebar-container"}, [
        (div {key: "left-sidebar-header", id: "left-sidebar-header", className: "sidebar-header"}, [
          (span {className: "sidebar-header-control", key: "new",  onClick: @handleNewDoc}, ["new"])
          (span {className: "sidebar-header-control", key: "open", onClick: @getOpenMenuClickHandler(true)}, ["open"])
        ])

        (div {id: "title", key: "title"}, [currentDoc.title])
        (div {id: "file-buttons", key: "file-buttons"}, [
          (span {className: "file-button", key: "download"}, ["download"])
          (span {className: "file-button", key: "stats"}, ["stats"])
        ])
        (Outline {key: "outline", chapters: currentDoc.chapters})
      ])
    else
      (span {})

  getOpenDocHandler: (doc) ->
    (event) =>
      AppAction.openDoc(doc)

      # Sync the doc list because currentDoc will be changing, so we can
      # no longer rely on it for the most current title for that doc.
      AppAction.syncDocList()

      @setState {showOpenMenu: false}

  handleNewDoc: ->
    AppAction.newDoc DreamDoc.fromHtmlStr(defaultNewDocHtml), defaultNewDocHtml

  handleShowOpenFile: ->
    # Dispatch a click event to the file chooser, so it displays an Open dialog.
    @refs.openFileChooser.getDOMNode().click()

  handleFileChooserChange: (event) ->
    files = @refs.openFileChooser.getDOMNode().files

    for file in files
      docFromFile file, (doc, html) ->
        AppAction.newDoc doc, html

    # TODO don't do this until we've actually finished reading all the files
    AppAction.syncDocList()

    @setState {showOpenMenu: false}

  getOpenMenuClickHandler: (showOpenMenu) ->
    (event) => @setState {showOpenMenu}

docFromFile = (file, onSuccess, onError) ->
  reader = new FileReader

  reader.onload = (response) ->
    fileName     = file.name ? file.fileName
    lastModified = if file.lastModifiedDate? then (new Date file.lastModifiedDate) else undefined
    html         = response.target.result

    doc = DreamDoc.fromFile fileName, lastModified, html

    if doc
      onSuccess doc, html
    else
      onError()

  reader.readAsText file