$ -> # like document ready
  window.Firmen.init()

class Firmen
#  name: "funcionarios"
  item_template : """
                  <tr class="item">
                    <td><% if (obj.branche) {  %><%= obj.branche %><% } %></td>
                    <td><%= obj.name %></td>
                    <td><%= obj.adresse %></td>
                    <td><%= obj.stadt %></td>
                    <td><%= obj.telefon1 %></td>
                    <td><%= obj.email %></td>
                  </tr>
                  """

  init: ->
    location = window.location.href.toString().split(window.location.host)[1]
    if location.indexOf("/") > -1
      @createTestData()
      @initMainPage()

  loadZip: () =>
    console.log 'loadZip'


  initMainPage: () =>
#    console.log 'json: ' + json
    settings =
      items: window.firmenData
      facets: { 'branche': 'Rubro', 'stadt': 'Ciudad' }
      resultSelector  : '#results'
      facetSelector   : '#facets'
      resultTemplate  : @item_template
      orderByOptions  : {'branche': 'Rubro', 'name': 'Nombre', 'adresse': 'Dirección', 'stadt': 'Ciudad'}
      facetContainer  : '<div class="facetsearch" id=<%= id %> ></div>',
      facetListContainer  : '<select class="facetlist"></select>'
      listItemTemplate  : '<option class=facetitem id="<%= id %>" value="<%= name %>"><%= name %> <span class=facetitemcount>(<%= count %>)</span></option>'
#      listItemTemplate   : '<div class=facetitem id="<%= id %>"><%= name %> <span class=facetitemcount>(<%= count %>)</span></div>',
      bottomContainer    : '<div class="bottomline"></div>',
      deselectTemplate   : '<span class=deselectstartover><button class="pure-button button-secondary" type="button">Reiniciar filtro</button></span>'
      facetTitleTemplate : '<span class=facettitle><%= title %>  &nbsp&nbsp;</span>'
      countTemplate      : '<span class=facettotalcount><%= count %> empresas encontradas.</span>',
      showMoreTemplate   : '<a id=showmorebutton>Más</a><br/><br/><br/><br/>'
      paginationCount    : 15
#      callbackResultUpdate: @resultUpdate
#      callbackUiCreated: @uiCreated
      callbackFacetedsearchresultupdate: @resultUpdate
      textFilter      : '#filter1'
      
    $.facetelize(settings)
    $("#filter1").prependTo($(".bottomline"))
    $("#filter1Lable").prependTo($(".bottomline"))

    $("#filter1").keypress (event) ->
      if(event.which == 13)
        event.preventDefault()
        $.facetUpdate()

#    $(settings.facetSelector).bind "facetuicreated", () ->
#      $("#firmenTable tr").click (e) ->
#        e.preventDefault()
#        Firmen.firmaClicked this

    $("#firmaDialog").click (e) ->
#      e.preventDefault()
      $('#firmaDialog').css("display", "none")



  resultUpdate: (items) =>
    $("#firmenTable tbody tr").unbind "click"
    $("#firmenTable tbody tr").click (e) ->
      e.preventDefault()
      display = $('#firmaDialog').css("display")
      if display is "none"
        $('#firmaDialog').css("display", "block")
        Firmen.firmaClicked this
      else
        $('#firmaDialog').css("display", "none")
    $("#firmenTable tbody tr").unbind "mouseover"
    $("#firmenTable tbody tr").mouseover (e) ->
      e.preventDefault()
      display = $('#firmaDialog').css("display")
      if display is "block"
        Firmen.firmaClicked this
#      console.log "hover"
  
  labels =
    'branche': 'Rubro'
    'name': 'Nombre'
    'adresse': 'Dirección'
    'stadt': 'Ciudad'
    'telefon1': 'Teléfono'
    'telefon2': 'Teléfono'
    'email': 'E-Mail'
    'webseite': 'Página Web'
    'facebook': 'Facebook'
    'twitter': 'Twitter'
    'beschreibung': 'Descipción'

  @firmaClicked: (e) =>
    json = window.firmenData
    name = $($(e).find("td")[1]).text()
    for firma in json
      if name is firma.name
        logo = "img/firmenlogos/"
        logo += if firma.logo then firma.logo else "dummy200.png"
        $("#firmaDialog img.logo").attr("src", logo)
        $("#firmaDialog img.logo").css("display", "block")
        dl = $("#firmaDialog dl")
        html = ""
        for key, label of labels
          value = firma[key]
          if value
            if key is 'webseite' 
              if (value.indexOf 'http://') is -1 then a = "http://#{value}" else a = value
              value = "<a href='#{a}'>#{value}</a>"
            if key is 'email'
              if (value.indexOf 'mailto://') is -1 then a = "mailto:#{value}" else a = value
              value = "<a href='#{a}'>#{value}</a>"
            html += "<dt>#{label}:</dt><dd>#{value}</dd>"
          dl.html html

        
  createTestData: () =>
    json = window.firmenData
    staedte = ['Asunción', 'Campo 9', 'Loma Plata', 'Encarnación', 'Hohenau', 'Villarica']
    branchen = ['Media', 'Salud', 'Transporte', 'Informática', 'Servicios', 'Finanzas', 
                'Gastronomia', 'Ventas', 'Mano de Obra', 'Industria', 'Arte & Cultura', 
                'Asociaciónes', 'Turismo', 'Educación', 'Deporte & Hobby', 'Animales', 
                'Alquileres', 'Inmuebles', 'Agronegocios']
#    sprachen = ["deutsch", "englisch", "russich", "italienisch", "spanisch", "guarani", "österreischich", "argentinisch"]
    for i in [100..601]
#      sprache = @getRandom(sprachen)
      row = {"id": "#{i}", "branche": @getRandom(branchen), "name":"Empresa #{i}", "adresse": "Calle #{i}", "stadt": @getRandom(staedte), "telefon1": "123456", "email": "info@empresa#{i}.com", "webseite": "http://firma#{i}.com", "facebook": "", "twitter": "", "beschreibung": "Hacemos de <b>todo</b>.<br/>Somos los <b>MEJORES</b>!<br/>Con nuestro apoyo ustedes logran sus <b>metas</b> ya antes del almuerzo.", "logo": "dummy200.png"}
#      row[sprache] = "ja"
      json.splice i, 0, row


  getRandom: (arr) =>
    max = arr.length
    min = 0
    i = Math.floor(Math.random() * (max))
    arr[i]
      
window.Firmen = new Firmen
 