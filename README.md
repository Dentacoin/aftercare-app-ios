
# Aftercare App

The Aftercare Mobile App is a product, which aims to form long-lasting dental care habits. 
A habit takes 66 days until it is integrated into the daily ritual of a person. Through notifications and reminders, 
our Mobile App will teach and navigate users (adults and children) to find ways to improve their dental hygiene and thus, 
form healthy habits, which will improve dental health and overall health. 
For children, forming dental hygiene habits will prevent the formation of deeper dental problems.

##  REQUIREMENTS

### PREREQUISITES

the github repo is located on the following address: https://github.com/Dentacoin/aftercare-app-ios 

Contains 3 branches:

1. master - updated with the latest state of develop branch on 09.05.2019
2. develop - updated to use swift 5.0 XCode 10.2.1 and latest version of its pod dependancies. Currently running most stable up-to-date version of the project
3. civic-login - older version of the project runing on swift 4.2 and XCode 10.0 with reworked login screen that uses civic library as pod dependacy (Most likely there is already newer version of the pod wich is not compatible with the current implementation)

### BUILD SETTINGS

This project uses shell script build_environment.sh to generate plist file which contains sensitive data related to the project such as Facebook app ID, Titter app ID, Google API Key etc.
Data that is not good to be exposed publicly on the git repository. the generated plist files and script are not part of the git and need to be setup manually.

+ You can read all the details how to setup the script to work with the project on the following link: https://gist.github.com/acrookston/55d69a16cd5363426dbf7a3d6a9ee6ce
+ Before you build the project make sure to run pod install in the root directory.

