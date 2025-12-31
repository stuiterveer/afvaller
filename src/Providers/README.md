# Purpose of this directory
This directory holds all the logic for the definition of external waste processors. If you want to add new ones, this is where you add one.

This README documents what is required for each provider. If this specification ever changes, the README will also be adjusted to always reflect the latest state.

# Creating a new provider
1. Create a new python file in this directory for the provider you want to add.
2. Open `qml/Main.qml` and edit the `providers` variable so this file is added to it:
    - The key of the new entry should contain the identifiable name of the waste processor and will be shown like that to the user.
    - The value of the new entry should hold the name of the python file, without the extension.
    - For example, if you want to create a new provider for a waste processor called "EX1" and created a file called `example.py` for it, add the following value to the `providers` object: `'EX1': 'example'`.
3. Define the required functions along with their return values, [further documented below](#required-functions).

# Required functions

## getCapabilities()
### Arguments
None.
### Return value
The function's return data should be an array, with any combination of the following possible strings as values:
* `'calendar'`: Return this value if the waste processor supports showing a waste calendar.
* `'containers'`: Return this value if the waste processor supports showing the locations of underground containers.

## validateAddress()
### Arguments
The app will call this function with the following arguments in the following order:
- **Postal code**: This is a string, which can be passed with or without spaces, and with or without capital letters. It's up to the provider to parse this correctly if needed by the waste processor.
- **House number**: This is a string, and contains the house number *without* any extension.
- **Extension**: This is a string, and contains the extension for the house number if applicable. If this is not provided, then it will be `None`.

### Return value
The functions return value should be a boolean. `True` if the address is valid for this waste processor, `False` if the address is not valid for this waste processor. "Not valid" can mean either an invalid address, or a valid address but not served by this waste processor.

## getYears()
**Only required if the provider has the `calendar` capability.**
### Arguments
None.
### Return value
The function's return data show be an array of all the years that it can get a calendar for. The years should be integers and should never be hardcoded (to prevent the app needing an update at least once a year just for updating the available years).

## getCalendar()
**Only required if the provider has the `calendar` capability.**
### Arguments
The app will call this function with the following arguments in the following order:
- **Postal code**: This is a string, which can be passed with or without spaces, and with or without capital letters. It's up to the provider to parse this correctly if needed by the waste processor.
- **House number**: This is a string, and contains the house number *without* any extension.
- **Extension**: This is a string, and contains the extension for the house number if applicable. If this is not provided, then it will be `None`.
- **Year**: This is a string, and specifies for which year the calendar is requested. Only the data for that specified year should be returned, other data should be filtered out.

### Return value
The function's return data should be an array, with each value in the array representing an individual collection date. Each of those dates should be structured as follows:

```json
{
    'date': ...,
    'dateInfo': ...,
    'types': [...]
}
```

Here's how each value in the object is formatted:
- `date`: A string with the date formatted as `'YYYY-MM-DD'`.
- `dateInfo`: A string representing when this date is compared to today's date, so that it can be shown in a specific way from within the app. It should have one of the following possible values:
    - `'today'` if it falls on the same date as today.
    - `'past'` if the date has already passed.
    - `'future`' if the date is at any point in the future.
- `types`: An array containing all trash types that are picked up on that day. This means that multiple pickups on the same day should be combined into the same object instead of providing multiple objects for the same date. The possible values are the keys of the `trashLut` variable in `qml/Main.qml`.

Any additional data in this object will be disregarded.

## getLocations()
**Only required if the provider has the `locations` capability.**

TODO: documentation needed