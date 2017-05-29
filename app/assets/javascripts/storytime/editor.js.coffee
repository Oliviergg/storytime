class Storytime.Dashboard.Editor
  init: () ->
    self = @

    mediaInstance = @initMedia()
    @initWysiwyg()

    # Init characters limit
    self.setHtmlTitleCharacterLimit()
    self.setHtmlDescriptionCharacterLimit()
    self.setExcerptCharacterLimit()
    self.setContentCharactersAndWordsCount()

    $('#post_html_title').keyup ->
      self.setHtmlTitleCharacterLimit()
      return

    $('#post_html_description').keyup ->
      self.setHtmlDescriptionCharacterLimit()
      return

    $('#post_excerpt').keyup ->
      self.setExcerptCharacterLimit()
      return

    $('.note-editable').keyup ->
      self.setContentCharactersAndWordsCount()
      return

    if $(".edit_post").length
      form = $(".edit_post").last()

      $("#preview_post").click(->
        self.autosavePostForm()
        return
      )

      if $("#main").data("preview")
        window.open $("#preview_post").attr("href")
    else
      form = $(".new_post").last()

      $("#preview_post").click(->
        form.data "unsaved-changes", false

        $("<input name='preview' type='hidden' value='true'>").insertAfter($(".new_post").children().first())
        $(".new_post").submit()
        return
      )

    # Setup Chosen select field
    $(".chosen-select").chosen
      no_results_text: "No results were found... Press 'Enter' to create a new tag named "
      placeholder_text_multiple: "Select or enter one or more Tags"
      search_contains: true

    # Setup datepicker
    $(".datepicker").datepicker
      dateFormat: "MM d, yy"

    # Setup timepicker
    $(".timepicker").timepicker
      showPeriod: true

    # On modal show initialize media upload
    $(document).on 'shown.bs.modal', () ->
      mediaInstance.initUpload()
      return

    # Add new tags
    $("#post_tag_ids").next("div").find(".search-field").children("input").on 'keyup', (e) ->
      if e.which is 13 and $("#post_tag_ids").next("div").find(".search-field").children("input").val().length > 0
        searched_tag = $("#post_tag_ids").next("div").find(".search-field").children("input").val()
        $("#post_tag_ids").append('<option value="nv__' + searched_tag + '">' + searched_tag + '</option>')

        selected_tags = $("#post_tag_ids").val() || []
        selected_tags.push "nv__#{searched_tag}"

        $("#post_tag_ids").val selected_tags
        $("#post_tag_ids").trigger 'chosen:updated'
      return

    # Set published field on Publish button click
    $(".publish").on 'click', () ->
      $("#post_published").val(1)
      form.data "unsaved-changes", false
      return

    # Add handler to monitor unsaved changes
    addUnloadHandler(form)
    return

  setHtmlTitleCharacterLimit: () ->
    $('#html-title-character-limit').html $('#html-title-character-limit').data('limit') - $('#post_html_title').val().length
    return

  setHtmlDescriptionCharacterLimit: () ->
    $('#html-description-character-limit').html $('#html-description-character-limit').data('limit') - $('#post_html_description').val().length
    return

  setExcerptCharacterLimit: () ->
    $('#excerpt-character-limit').html $('#excerpt-character-limit').data('limit') - $('#post_excerpt').val().length
    return

  setContentCharactersAndWordsCount: () ->
    $('#content-characters-count').html this.unHTML($('.note-editable').html()).length
    $('#content-words-count').html this.unHTML($('.note-editable').html()).split(' ').filter((n) -> return n != '').length
    return

  unHTML: (html) ->
    return html.replace(/<(?:.|\n)*?>/gm, '').replace(/&nbsp;/gi, ' ').replace(/&amp;/gi, '&').replace(/&quot;/gi, '"').replace(/&lt;/gi, '<').replace(/&gt;/gi, '>')

  initMedia: () ->
    mediaInstance = new Storytime.Dashboard.Media()
    mediaInstance.initPagination()
    mediaInstance.initInsert()
    mediaInstance.initFeaturedImageSelector()
    mediaInstance.initSecondaryImageSelector()

    $(document).on 'shown.bs.modal', ()->
      mediaInstance.initUpload()
      return

    mediaInstance

  initWysiwyg: () ->
    self = @

    # Summernote config and setup
    $(".summernote").summernote
      codemirror:
        htmlMode: true
        lineNumbers: true
        lineWrapping: true
        mode: 'text/html'
        theme: 'default',
        smartIndent: false
      height: 200
      minHeight: null
      maxHeight: null
      toolbar: [
        ['style', ['style']]
        ['font', ['bold', 'italic', 'underline', 'superscript', 'subscript', 'strikethrough', 'clear']]
        # ['fontname', ['fontname']]
        # ['fontsize', ['fontsize']]
        ['color', ['color']]
        ['para', ['ul', 'ol', 'paragraph']]
        # ['height', ['height']]
        ['table', ['table']]
        ['insert', ['link', 'picture', 'video', 'hr']]
        ['view', ['fullscreen', 'codeview']]
        ['editing', ['undo', 'redo']]
        ['help', ['help']]
      ]
      onblur: ->
        $(".summernote").data("range", document.getSelection().getRangeAt(0))
        return
      onfocus: ->
        self.updateLater(10000) if $(".edit_post").length
        return
      onkeyup: ->
        form = if $(".edit_post").length then $(".edit_post").last() else $(".new_post").last()
        form.data "unsaved-changes", true
        return
      onImageUpload: (files, editor, $editable) ->
        $("#media_file").fileupload('send', {files: files})
          .success((result, textStatus, jqXHR) ->
            editor.insertImage($editable, result.file_url)
            return
          )
        return

    # Show Gallery when using Summernote insertPicture modal
    $(".note-image-dialog").on 'shown.bs.modal', () ->
      if $("#media_gallery").length > 0
        $(".note-image-dialog").find(".row-fluid").append(
          "<div id='gallery_copy'>
            <h5>Gallery</h5>
            <div id='media_gallery'>" +
              $("#media_gallery").html() +
            "</div>
          </div>")
      return

    # Remove Gallery when closing out Summernote insertPicture modal
    $(".note-image-dialog").on 'hide.bs.modal', () ->
      $("#gallery_copy").remove()
      return

  autosavePostForm: () ->
    self = @
    post_id = $("#main").data("post-id")
    dashboard_namespace = $("#main").data("dashboard-namespace")

    data = []
    data.push {name: "post[draft_content]", value: $(".summernote").code()}

    form = if $(".edit_post").length then $(".edit_post").last() else $(".new_post").last()
    form.data "unsaved-changes", false

    $.ajax(
      type: "POST"
      url: "#{dashboard_namespace}/posts/#{post_id}/autosaves"
      data: data
    )

  updateLater: (timer) ->
    self = @
    timer = 120000  unless timer?

    form = if $(".edit_post").length then $(".edit_post").last() else $(".new_post").last()

    timeoutId = window.setTimeout((->
      if form.data("unsaved-changes") is true
        self.autosavePostForm().done(->
          self.updateLater timer

          time_now = new Date().toLocaleTimeString()
          $("#draft_last_saved_at").html "Draft saved at #{time_now}"
          return
        ).fail(->
          console.log "Something went wrong while trying to autosave..."
          return
        )

        return
      else
        self.updateLater timer
        return
    ), timer)
    return

  addUnloadHandler = (form) ->
    form.find("input, textarea").on("keyup", ->
      form.data "unsaved-changes", true
      return
    )

    $(".save").click(->
      form.data "unsaved-changes", false
      return
    )

    $(window).on "beforeunload", ->
      return "You haven't saved your changes." if form.data "unsaved-changes"
