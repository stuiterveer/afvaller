import urllib.request
import urllib.error
import json
from datetime import date, datetime

from bs4 import BeautifulSoup

def getCapabilities():
    return ['calendar']

def getCalendar(postalCode, houseNumber, numberExtension, year):
    dateLookup = {
        'januari': '01',
        'februari': '02',
        'maart': '03',
        'april': '04',
        'mei': '05',
        'juni': '06',
        'juli': '07',
        'augustus': '08',
        'september': '09',
        'oktober': '10',
        'november': '11',
        'december': '12'
    }
    postalCode = postalCode.replace(' ', '')
    url = 'https://mijnafvalwijzer.nl/nl/' + postalCode + '/' + houseNumber + '/' + (numberExtension if numberExtension is not None else '')

    try:
        headers = {}
        headers['User-Agent'] = 'Mozilla/5.0'
        req = urllib.request.Request(url, headers = headers)
        resp = urllib.request.urlopen(req)
    except urllib.error.HTTPError as err:
        return err

    returnData = resp.read()
    resp.close()

    parser = BeautifulSoup(returnData, 'html.parser')

    trashCollection = parser.find_all(class_='ophaaldagen')[1].find_all(class_='wasteInfoIcon')

    returnData = []
    today = date.today()

    for x in trashCollection:
        dataPoint = {}
        trashData = x.find_all('span')

        dateArr = trashData[0].string.split()
        dataPoint['date'] = year + '-' + dateLookup[dateArr[2]] + '-' + dateArr[1]

        collectionDate = date(int(year), int(dateLookup[dateArr[2]]), int(dateArr[1]))

        if collectionDate < today:
            dataPoint['dateInfo'] = 'past'
        elif collectionDate == today:
            dataPoint['dateInfo'] = 'today'
        elif collectionDate > today:
            dataPoint['dateInfo'] = 'future'

        if trashData[1].string == 'Restafval':
            dataPoint['type'] = 'residual_waste'
        elif trashData[1].string == 'MD':
            dataPoint['type'] = 'md'
        elif trashData[1].string == 'Plastic en kunststof' or trashData[1].string == 'Plastic':
            dataPoint['type'] = 'plastic'
        elif trashData[1].string == 'Papier en karton' or trashData[1].string == 'Oud papier':
            dataPoint['type'] = 'paper'
        elif trashData[1].string == 'Groente, Fruit en Tuinafval' or trashData[1].string == 'GFT-afval':
            dataPoint['type'] = 'gft'
        elif trashData[1].string == 'Mobiel Scheidingsstation' or trashData[1].string == 'Takkenroute':
            dataPoint['type'] = 'pruning_waste'
        elif trashData[1].string == 'Droge herbruikbare materialen':
            dataPoint['type'] = 'dry_recyclables'
        elif trashData[1].string == 'Plastic, Metalen en Drankkartons':
            dataPoint['type'] = 'pmd'
        elif trashData[1].string == 'Kerstbomen':
            dataPoint['type'] = 'christmas_trees'
        elif trashData[1].string == 'Grofvuil':
            dataPoint['type'] = 'bulky_waste'
        elif trashData[1].string == 'Textiel':
            dataPoint['type'] = 'textiles'
        else:
            dataPoint['type'] = trashData[1].string

        returnData.append(dataPoint)

    return returnData

def getYears():
    currentYear = datetime.now().year
    data = [currentYear]

    if datetime.now().month == 12:
        data.append(currentYear + 1)

    return data

def validateAddress(postalCode, houseNumber, numberExtension):
    params = '?postcode=' + postalCode
    params += '&huisnummer=' + houseNumber
    params += '&toevoeging=' + (numberExtension if numberExtension is not None else '')

    url = 'https://mijnafvalwijzer.nl/site/postcodeinfo{}'.format(params)
    url = url.replace(" ", "%20")

    try:
        headers = {}
        headers['User-Agent'] = 'Mozilla/5.0'
        req = urllib.request.Request(url, headers = headers)
        resp = urllib.request.urlopen(req)
    except urllib.error.HTTPError as err:
        return False

    returnData = resp.read()
    resp.close()

    returnDataJson = json.loads(returnData)

    if returnDataJson['response'] == 'OK':
        return True
    else:
        return False