exports.setMarkersWithCenter = (map, latiarray, longiarray) ->
  return  unless latiarray.length is longiarray.length
  total_locations = latiarray.length
  minLongi = null
  minLati = null
  maxLongi = null
  maxLati = null
  totalLongi = 0.0
  totalLati = 0.0
  i = 0

  while i < total_locations
    minLati = latiarray[i]  if not minLati? or minLati > latiarray[i]
    minLongi = longiarray[i]  if not minLongi? or minLongi > longiarray[i]
    maxLati = latiarray[i]  if not maxLati? or maxLati < latiarray[i]
    maxLongi = longiarray[i]  if not maxLongi? or maxLongi < longiarray[i]
    i++
  ltDiff = maxLati - minLati
  lgDiff = maxLongi - minLongi
  delta = (if ltDiff > lgDiff then ltDiff else lgDiff)
  if delta > 180
    delta = 180
    map.setLocation
      animate: true
      latitude: 29.76429
      longitude: -95.38370
      latitudeDelta: delta
      longitudeDelta: delta
  else
    if total_locations > 0 and delta > 0
      map.setLocation
        animate: true
        latitude: ((maxLati + minLati) / 2)
        longitude: ((maxLongi + minLongi) / 2)
        latitudeDelta: delta
        longitudeDelta: delta

  return