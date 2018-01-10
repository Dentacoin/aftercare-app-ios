#  Dentacare

<#One Paragraph of project description#>

##  REQUIREMENTS

### PREREQUISITES

+ Mac computer
+ Xcode
+ Developer account
+ iTunes Connect account (Optional)
+ Clone the repository
+ [Cocoapods dependency manager](https://cocoapods.org/)

### PODS

+ Navigate to the folder containing the Podfile in your Terminal app.
+ Now install the pod (and any other necessary project dependencies) by executing the command: `pod install`.
+ Open *Aftercare.xcworkspace* and build.

> **NB! Steps above are necessary only if you've decided to not add Pods folder to git repository.**

### BUILD SETTINGS

Base SDK: <#The SDK you link against#>

### RUNTIME SETTINGS

Deployment Target: <#Minimum required iOS version you application needs to run#>

> **NB! You can build an application with SDK 7 that runs under iOS 6. But then you have to take care to not use any function or method that is not available on iOS 6. If you do, your application will crash on iOS 6 as soon as this function is used.**

### PROVISIONING

<#Information non-automatic provisioning profiles (Optional)#>

### DEBUG

<#Specific debug information (e.g. "Camera functionality can not be tested in the Simulator") (Optional)#>

### APPSTORE

<#Specific information needed for the appstore (Optional)#>

### ARCHIVE

+ Select Generic iOS Device for building.
+ Build the project using `Project -> Archive`.
+ Open `Window -> Organizer` (if not already open). Choose the last build and select `Upload to App Store…`. Follow the instructions.
+ Go to ***iTunes Connect*** and submit the build for distribution on App Store or for Beta Testing.

## CONTACTS

- Developer: Dimitar Grudev

------

Copyright © 2017 Dimitar Grudev. All rights reserved.
