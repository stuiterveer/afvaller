# Purpose of this directory
This directory holds all the logic for the definition of external waste processors. If you want to add ned ones, this is where you add one.

# Creating a new provider
1. Create a new python file in this directory for the provider you want to add.
2. Open `qml/Main.qml` and edit the `providers` variable so this file is added to it:
    - The key of the new entry should contain the identifiable name of the waste processor and will be shown like that to the user.
    - The value of the new entry should hold the name of the python file, without the extension.
    - For example, if you want to create a new provider for a waste processor called "EX1" and created a file called `example.py` for it, add the following value to the `providers` object: `'EX1: 'example'`.
3. In your new script:
    1. Add a function called `getCapabilities()` that returns an array containing all features are supported by this provider. Possible values in this array:
        - `'calendar'` for the waste calendar.
        - `'containers'` for the locations of underground containers.
    2. If your provider supports the waste calendar, then define a function called `getCalendar()` that returns the trash dates in an array. Further explanation about the requirements of the function can be found below.
    3. If your provider supports container locations, then define a function called `getLocations()` that returns the locations in an array. TODO: further documentation needed


# getCalendar()
## Arguments
The app will call this function with the following arguments in the following order:
- **Postal code**: This is a string, which can be passed with or without spaces, and with or without capital letters. It's upp to the provider to parse this correctly if needed by the waste processor.
- **House number**: This is a string, and contains the house number *without* any extension.
- **Extension**: This is a string, and contains the extension for the house number if applicable. If this is not provided, then it will be `None`.
- **Year**: This is an integer, and specifies for which year the calendar is requested. Only the data for that specified year should be returned, other data should be filtered out.

## Return value
The function's return data should be an array, with each value in the array representing an individual collection date. Each of those dates should be structured as follows:

```json
{
    'date': ...,
    'dateInfo': ...,
    'types': [...]
}
```

Any additional data in this object will be disregarded.