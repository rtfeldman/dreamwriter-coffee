_ = require "lodash"

module.exports = DreamDoc =
  fromHtmlDoc: (doc) ->
    title:    DreamDoc.titleFromNode doc
    chapters: DreamDoc.chaptersFromNode doc

  titleFromNode: (node) ->
    titleElem = node.querySelector "h1"
    titleElem?.innerText?.trim() ? ""

  chaptersFromNode: (node) ->
    chapterHeadings = node.querySelectorAll "h2"
    _.map chapterHeadings, (heading) ->
      {heading: heading.innerText?.trim() ? ""}
