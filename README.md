# micard

edit the profile and save in the DB.

Hot reload or Hot restart works fine. But when you reinstall the app and try to run it, the app fails.

In iOS, when we retrieve the saved file path from the DB after killing the app and restarting it, it gives the following error...

FileSystemException (FileSystemException: Cannot open file, path = '/Users/sri/Library/Developer/CoreSimulator/Devices/889E9CD0-848C-4AD5-83AF-265A4E79A7ED/data/Containers/Data/Application/38E2DB72-2AE4-4D62-A5CB-E76D241029C7/MiCard/image_picker_929558B0-A89B-4E70-88A6-21860AB124FD-53927-0001833E45DF85FB.jpg' (OS Error: No such file or directory, errno = 2))
