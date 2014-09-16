_ = require "lodash"

# Note: must use [\s\S]* instead of .* because in JavaScript RegExes the dot never matches newlines, even with /m
htmlBody = /<\s*body[^>]*>([\s\S]*)<\s*\/\s*body\s*>/igm

module.exports = DreamDoc =
  fromHtmlDoc: (doc) ->
    title:    DreamDoc.titleFromNode doc
    chapters: DreamDoc.chaptersFromNode doc

  fromHtmlStr: (html) ->
    DreamDoc.fromHtmlDoc (DreamDoc.htmlStrToHtmlDoc html)

  htmlStrToHtmlDoc: (html) ->
    docElem = document.createElement 'div'
    docElem.innerHTML = "<div id='loaded-content'>#{html}</div>"

    docElem.firstChild

  fromFile: (fileName, lastModified, html) ->
    _.defaults DreamDoc.fromHtmlStr(html), 
      title: fileName.replace(/.html$/, '').replace('_', ' ')

  titleFromNode: (node) ->
    titleElem = node.querySelector "h1"
    titleElem?.textContent?.trim() ? ""

  chaptersFromNode: (node) ->
    chapterHeadings = node.querySelectorAll "h2"
    _.map chapterHeadings, (heading) ->
      {heading: heading.textContent?.trim() ? ""}

  wrapInDocumentMarkup: (bodyHtml) -> """
    <html>
      <head>
        <meta charset="utf-8"/>
        <meta name="generator" content="http://dreamwriter.io"/>
        <style type="text/css">
            @page {
                margin: 0.8cm;
            }

            ::selection {
                background: #e0e0e0;
                color: inherit;
                text-shadow: inherit;
            }

            ::-moz-selection {
                background: #e0e0e0;
                color: inherit;
                text-shadow: inherit;
            }

            .note-highlight {
                background-color: #c0c0c0;
            }

            body {
                font-size: 12px;
                color: black;
                font-family: Georgia, PT Serif, Times New Roman, serif;
                overflow-x: visible;
                width: 42em;
                padding: 6em 1.5em 6em 1.5em;
                margin-left: auto;
                margin-right: auto;
                word-wrap: break-word;
            }

            h1, h2, h3, h4 {
                font-weight: normal;
                font-family: inherit;
                text-align: center;
                margin: 0;
                line-height: 1.1em;
            }

            h1 {
                margin-bottom: 24px;
                font-size: 48px;
            }

            h2 {
                font-size: 36px;
                margin-top: 36px;
                margin-bottom: 36px;
                page-break-before: always;
            }

            h3 {
                font-size: 24px;
                margin-bottom: 96px;
                line-height: 1.5em;
            }

            p, div {
                font-family: inherit;
                text-indent: 30px;
                margin: 0;
                line-height: 1.5em;
                font-size: 18px;
            }

            p > *, div > * {
                text-indent: 0;
            }

            hr {
                width: 20%;
                margin-top: 24px;
                margin-bottom: 24px;
                margin-left: auto;
                margin-right: auto;
                background-color: black;
            }

            blockquote {
                margin-left: 1em;
                page-break-inside: avoid;
            }
        </style>
      </head>
      <body>#{bodyHtml}</body>
    </html>
  """