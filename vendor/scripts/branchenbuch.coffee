$ -> # like document ready
#  supportedLanguages = 
#    es: 'es'
#    de: 'de'
#  broserLanguage = window.navigator.userLanguage || window.navigator.language
#  language = if window.Cookies.readCookie 'language' then broserLanguage else 'de'

  language = (window.Cookies.readCookie 'language') || 'de'
#  console.log window.Cookies.readCookie 'language'
  T9n.setLanguage language
  t9n()
  window.Firmen.init()
  $('.switchLanguage').on 'click', switchLanguage 
    
switchLanguage = (e) ->
  e.preventDefault()
  language = e.target.getAttribute('data-language')
  window.Cookies.createCookie('language', language, 7)
  if T9n.getLanguage() isnt language
    T9n.setLanguage language
    t9n()
    $.facetelize(window.Firmen.settings())
    $('#firmaDialog').css("display", "none")

  
t9n = () ->
  elems = $("[data-t9n]")
  for elem in elems
    elem = $(elem)
    key = elem.attr("data-t9n")
    elem.text T9n.get key



class Firmen
  item_template : """
                  <tr class="item">
                    <td><% if (obj.branche) {  %><%= window.extractValue(obj.branche) %><% } %></td>
                    <td><%= obj.name %></td>
                    <td><%= obj.adresse %></td>
                    <td><%= obj.stadt %></td>
                    <td><%= obj.telefon1 %></td>
                    <td><%= obj.email %></td>
                  </tr>
                  """

  init: ->
    location = window.location.href.toString().split(window.location.host)[1]
    if location is '/'
      @createTestData()
      @initMainPage()


  initMainPage: () =>
    $.facetelize(@settings())

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

    # init leaflet
    L.Icon.Default.imagePath = '../img/leaflet'

  settings: ->
    items: window.firmenData
    facets: { 'branche': T9n.get('branche'), 'stadt': T9n.get('stadt') }
    resultSelector  : '#results'
    facetSelector   : '#facets'
    resultTemplate  : @item_template
    orderByOptions  : {'branche': T9n.get('branche'), 'name': T9n.get('name'), 'adresse': T9n.get('adresse'), 'stadt': T9n.get('stadt')}
    facetContainer  : '<div class="facetsearch" id=<%= id %> ></div>',
    facetListContainer  : '<select class="facetlist"></select>'
    listItemTemplate  : '<option class=facetitem id="<%= id %>" value="<%= name %>"><%= name %> <span class=facetitemcount>(<%= count %>)</span></option>'
    bottomContainer    : '<div class="bottomline"></div>',
    deselectTemplate   : '<span class=deselectstartover><button class="pure-button button-secondary" type="button">' + T9n.get('Reiniciar filtro')  + '</button></span>'
    facetTitleTemplate : '<span class=facettitle><%= title %>  &nbsp&nbsp;</span>'
    countTemplate      : "<span class=facettotalcount><%= count %> #{T9n.get 'empresas encontradas.' }</span>",
    showMoreTemplate   : "<a id=showmorebutton> #{T9n.get 'Más'} </a><br/><br/><br/><br/>"
    paginationCount    : 12
    noResults          : "<div class=results>#{T9n.get 'noResults'}</div>",
#      callbackResultUpdate: @resultUpdate
#      callbackUiCreated: @uiCreated
    callbackFacetedsearchresultupdate: @resultUpdate
    textFilter      : '#filter1'
      
      
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
  
  labels = ->
    'branche': T9n.get 'branche'
    'name': T9n.get 'name'
    'adresse': T9n.get 'adresse'
    'stadt': T9n.get 'stadt'
    'telefon1': T9n.get 'telefon1'
    'telefon2': T9n.get 'telefon2'
    'email': T9n.get 'email'
    'webseite': T9n.get 'webseite'
    'facebook': T9n.get 'facebook'
    'twitter': T9n.get 'twitter'
    'beschreibung': T9n.get 'beschreibung'

  @map = null
  @marker = null
    
  @firmaClicked: (e) =>
    json = window.firmenData
    name = $($(e).find("td")[1]).text()
    for firma in json
      if name is firma.name
        @showFirma firma
        @showMap firma
        
  @showFirma: (firma) =>
    logo = "img/firmenlogos/"
    logo += if firma.logo then firma.logo else "dummy200.png"
    $("#firmaDialog img.logo").attr("src", logo)
    $("#firmaDialog img.logo").css("display", "block")
    dl = $("#firmaDialog dl")
    html = ""
    for key, label of labels()
      value = firma[key]
      if value
        if key is 'webseite'
          if (value.indexOf 'http://') is -1 then a = "http://#{value}" else a = value
          value = "<a href='#{a}'>#{value}</a>"
        if key is 'email'
          if (value.indexOf 'mailto://') is -1 then a = "mailto:#{value}" else a = value
          value = "<a href='#{a}'>#{value}</a>"
        value = @extractValue value
        html += "<dt>#{label}:</dt><dd>#{value}</dd>"
      dl.html html

  @extractValue: (value) ->
    if 'object' is typeof value
      value = value[T9n.getLanguage()]
    else
      value
  window.extractValue = @extractValue

  @showMap: (firma) =>          
    if firma.lat
      $("#firmaKarte").css("display", "block")
      point = if firma.lat then [firma.lat, firma.long] else [-25.3078, -57.5853]
      if @map
        @map.panTo point
        @marker.setLatLng point
      else
        @map = L.map('firmaKarte').setView(point, 13)
        # set user location
#        @map.locate({setView: true, maxZoom: 8})
        layerAttributes =
          attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', layerAttributes).addTo(@map)
        @marker = L.marker(point).addTo(@map)
#          .bindPopup('A pretty CSS3 popup. <br> Easily customizable.')
#          .openPopup()
    else
      $("#firmaKarte").css("display", "none")

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


