import urllib.request
import urllib.error
import json
from datetime import date, datetime

def getCapabilities():
    return ['calendar', 'containers']

def getCalendar(postalCode, houseNumber, numberExtension, year):
    params = '?postal_code=' + postalCode
    params += '&house_number=' + houseNumber
    if numberExtension is not None:
        params += '&house_number_extension=' + numberExtension
    params += '&year=' + year
    params += '&types[]=residual_waste'
    params += '&types[]=gft'
    params += '&types[]=paper'
    params += '&types[]=pruning_waste'
    params += '&types[]=pmd'
    params += '&types[]=best_bag'
    params += '&types[]=christmas_trees'

    url = 'https://data.rd4.nl/api/v1/waste-calendar{}'.format(params)
    url = url.replace(" ", "%20")

    try:
        conn = urllib.request.urlopen(url)
    except urllib.error.HTTPError as err:
        return []
    returnData = conn.read()
    conn.close()

    data = json.loads(returnData)['data']['items'][0]

    i = len(data) - 1
    today = date.today()
    while i >= 0:
        dateArr = data[i]['date'].split('-')
        collectionDate = date(int(dateArr[0]), int(dateArr[1]), int(dateArr[2]))

        if collectionDate < today:
            data[i]['dateInfo'] = 'past'
        elif collectionDate == today:
            data[i]['dateInfo'] = 'today'
        elif collectionDate > today:
            data[i]['dateInfo'] = 'future'

        data[i]['types'] = []
        data[i]['types'].append(data[i]['type'])

        if i != len(data) - 1:
            if data[i]['date'] == data[i+1]['date']:
                data[i]['types'].append(data[i+1]['type'])
                del data[i+1]
        i -= 1

    return data

def getLocations():
    params = '?types[]=GFT'
    params += '&types[]=GLAS'
    params += '&types[]=LUIER'
    params += '&types[]=PAPIER'
    params += '&types[]=PMD'
    params += '&types[]=REST'
    params += '&types[]=TEXTIEL'

    url = 'https://data.rd4.nl/api/v1/locations{}'.format(params)

    try:
        conn = urllib.request.urlopen(url)
    except urllib.error.HTTPError as err:
        return []
    returnData = conn.read()
    conn.close()

    return json.loads(returnData)['data']

def getYears():
    currentYear = datetime.now().year
    return [currentYear, currentYear + 1]