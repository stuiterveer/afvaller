import urllib.request
import urllib.error
import json

def postalToGeo(address):
    params = '?country=nl'
    params += '&postalcode=' + address['postalCode']
    params += '&format=geojson'

    url = 'https://nominatim.openstreetmap.org/search{}'.format(params)
    url = url.replace(" ", "%20")

    try:
        conn = urllib.request.urlopen(url)
    except urllib.error.HTTPError as err:
        return []
    returnData = conn.read()
    conn.close()

    return json.loads(returnData)['features'][0]
