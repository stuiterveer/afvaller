import urllib.request
import urllib.error
import json
from datetime import date

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

            data[i]['types'] = []
            if data[i]['wasteType']['code'] == 'PMD':
                data[i]['types'].append('pmd')
            elif data[i]['wasteType']['code'] == 'GFT':
                data[i]['types'].append('gft')
            elif data[i]['wasteType']['code'] == 'PAP':
                data[i]['types'].append('paper')
            elif data[i]['wasteType']['code'] == 'RST':
                data[i]['types'].append('residual_waste')

            if i != len(data) - 1:
                if data[i]['date'] == data[i+1]['date']:
                    data[i]['types'].append(data[i+1]['type'])
                    del data[i+1]
        else:
            del data[i]

        i -= 1

    return data