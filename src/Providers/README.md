# Purpose of this directory
This directory holds all the logic for the definition of external waste processors. If you want to add ned ones, this is where you add one.

# Creating a new provider
1. Create a new python file in this directory for the provider you want to add.
2. Open `qml/Main.qml` and edit the `providers` variable so this file is added to it:
    - The key of the new entry should contain the identifiable name of the waste processor and will be shown like that to the user.
    - The value of the new entry should hold the name of the python file, without the extension.
    - For example, if you want to create a new provider for a waste processor called "EX1" and created a file called `example.py` for it, add the following value to the `providers` object: `'EX1: 'example'`