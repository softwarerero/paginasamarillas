@T9n = class T9n

  @maps: {}
  @defaultLanguage: 'en'
  @language: ''
  @missingPrefix = ">"
  @missingPostfix = "<"

  @map: (language, map) ->
    if(!@maps[language]) 
      @maps[language] = {}
    @registerMap(language, '', false, map)

  @get: (label, args = {}, markIfMissing = true) ->
    if typeof label != 'string' 
      return ''
    ret = @maps[@language]?[label] ||
      @maps[@defaultLanguage]?[label] ||
      if markIfMissing then @missingPrefix + label + @missingPostfix else label
    if Object.keys(args).length == 0 then ret else @replaceParams ret, args
  
  @registerMap = (language, prefix, dot, map) ->
    if typeof map == 'string' 
      @maps[language][prefix] = map
    else if typeof map == 'object'
      if dot 
        prefix = prefix + '.'
      for key, value of map
        @registerMap(language, prefix + key, true, value)        

  @getLanguage: () ->
    return @language

  @getLanguages: () ->
    return Object.keys(@maps).sort()

  @setLanguage: (language) ->
    if(!@maps[language] || @language == language) 
      return;
    @language = language

  @replaceParams = (str, args) ->
    for key, value of args
      re = new RegExp "@{#{key}}", 'g'
      str = str.replace re, value
    str
    
  @isDefined: (label) ->
    !!(@maps[@language]?[label] || @maps[@defaultLanguage]?[label])

@t9n = (x, includePrefix, params) -> T9n.get(x)

