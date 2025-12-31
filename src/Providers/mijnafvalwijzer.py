import urllib.request
import urllib.error
import json

def getCapabilities():
    return []

def validateAddress(postalCode, houseNumber, numberExtension):
    params = '?postcode=' + postalCode
    params += '&huisnummer=' + houseNumber
    params += '&toevoeging=' + (numberExtension if numberExtension is not None else '')

    url = 'https://mijnafvalwijzer.nl/site/postcodeinfo{}'.format(params)
    url = url.replace(" ", "%20")

    try:
        conn = urllib.request.urlopen(url)
    except urllib.error.HTTPError as err:
        return False

    returnData = conn.read()
    conn.close()

    returnDataJson = json.loads(returnData)

    if returnDataJson['response'] == 'OK':
        return True
    else:
        return False