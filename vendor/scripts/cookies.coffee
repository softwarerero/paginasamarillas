window.Cookies = class @Cookies

  @createCookie: (name,value,days) ->
    if (days)
      date = new Date()
      date.setTime(date.getTime()+(days*24*60*60*1000))
      expires = "; expires="+date.toGMTString()
    else
      expires = ""
    document.cookie = name+"="+value+expires+"; path=/"

  @readCookie: (name) ->
    nameEQ = name + "="
    ca = document.cookie.split(';')
    for c in ca
      while (c.charAt(0) is ' ') 
        c = c.substring(1,c.length)
      if (c.indexOf(nameEQ) == 0)
        return c.substring(nameEQ.length,c.length)
    null
  
  eraseCookie: (name) ->
    createCookie(name,"",-1)