import urllib.request
import urllib.error
import json
from datetime import date, datetime

# Lookup table for trash types
RovaTrashTypeLUT = {
'RST':'Restafval',
'GFT':'GFT en etensresten',
'PAP':'Oud papier en karton',
'PMD':'PMD-verpakkingen'
}

def getCapabilities():
    return ['calendar']

def getCalendar(postalCode, houseNumber, numberExtension, year):
    params = '?postalcode=' + postalCode
    params += '&houseNumber=' + houseNumber
    params += '&addition=' + (numberExtension if numberExtension is not None else '')
    params += '&year=' + year
    
    url = 'https://rova.nl/api/waste-calendar/year{}'.format(params)
    url = url.replace(" ", "%20")

    try:
        conn = urllib.request.urlopen(url)
    except urllib.error.HTTPError as err:
        return []
    returnData = conn.read()
    conn.close()

    data = json.loads(returnData)

    i = len(data) - 1
    today = date.today()
    while i >= 0:
        data[i]['date'] = data[i]['date'].split('T')[0]
        dateArr = data[i]['date'].split('-')
        if dateArr[0] == year:
            collectionDate = date(int(dateArr[0]), int(dateArr[1]), int(dateArr[2]))

            if collectionDate < today:
                data[i]['dateInfo'] = 'past'
            elif collectionDate == today:
                data[i]['dateInfo'] = 'today'
            elif collectionDate > today:
                data[i]['dateInfo'] = 'future'

            if data[i]['wasteType']['code'] in RovaTrashTypeLUT:
                data[i]['type'] = RovaTrashTypeLUT[data[i]['wasteType']['code']]
        else:
            del data[i]

        i -= 1

    return data

def getYears():
    currentYear = datetime.now().year
    data = [currentYear]

    if datetime.now().month == 12:
        data.append(currentYear + 1)

    return data

def validateAddress(postalCode, houseNumber, numberExtension):
    params = '?postalCode=' + postalCode
    params += '&housenumber=' + houseNumber
    params += '&addition=' + (numberExtension if numberExtension is not None else '')

    url = 'https://rova.nl/api/address{}'.format(params)
    url = url.replace(" ", "%20")

    try:
        conn = urllib.request.urlopen(url)
    except urllib.error.HTTPError as err:
        return False

    return True