#!/bin/sh

#  build_environment.sh
#
#  Created by Andrew C on 7/27/15.
#  Released under MIT LICENSE
#  Copyright (c) 2015 Andrew Crookston.


cd "${PROJECT_DIR}"

dir=${PROJECT_DIR}/config/environments
echo "Starting environment ${ENVIRONMENT} configuration for ${PROJECT_NAME}/${PROJECT_FOLDER} with config in " $dir
echo "Host: " `hostname`

# environment variable from value passed in to xcodebuild.
# if not specified, we default to DEV
env=${ENVIRONMENT}
if [ -z "$env" ]
then
env="development"
fi
echo "Using $env environment"

# copy the environment-specific file
cp $dir/$env.plist $dir/environment.plist

# Date and time that we are running this build
buildDate=`date "+%F %H:%M:%S"`
todaysDay=`date "+%d"`

# app settings
appName=`/usr/libexec/PlistBuddy -c "Print :AppName" "$dir/environment.plist"`
appGroup=`/usr/libexec/PlistBuddy -c "Print :AppGroup" "$dir/environment.plist"`
version=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$dir/environment.plist"`
hostname=`/usr/libexec/PlistBuddy -c "Print :HostName" "$dir/environment.plist"`
hostscheme=`/usr/libexec/PlistBuddy -c "Print :HostScheme" "$dir/environment.plist"`
bundle=`git rev-list master |wc -l | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`


if [ "$env" == "development" ]
then
hostname=`hostname`
# need to dynamically append today's day for non-prod
appName="$appName-$todaysDay"
# Last hash from the current branch
#version=`git log --pretty=format:"%h" -1`
fi

buildhost=`hostname`

# Build the preprocess file
cd "${PROJECT_DIR}"
preprocessFile="environment_preprocess.h"

echo "Creating header file ${PROJECT_DIR}/${preprocessFile}"

echo "//------------------------------------------" > $preprocessFile
echo "// Auto generated file. Don't edit manually." >> $preprocessFile
echo "// See build_environment script for details." >> $preprocessFile
echo "// Created $buildDate" >> $preprocessFile
echo "//------------------------------------------" >> $preprocessFile
echo "" >> $preprocessFile
echo "#define ENV                $env" >> $preprocessFile
echo "#define ENV_APP_NAME       $appName" >> $preprocessFile
echo "#define ENV_APP_GROUP      $appGroup" >> $preprocessFile
echo "#define ENV_APP_VERSION    $version" >> $preprocessFile
echo "#define ENV_HOST_NAME      $hostname" >> $preprocessFile
echo "#define ENV_BUILD_HOST     $buildhost" >> $preprocessFile
echo "#define ENV_BUNDLE_VERSION $bundle" >> $preprocessFile
echo "#define ENV_HOST_SCHEME    $hostscheme" >> $preprocessFile

# dump out file to build log
cat $preprocessFile

# Force the system to process the plist file
echo "Touching all plists at: ${PROJECT_DIR}/**/Info.plist"
touch ${PROJECT_DIR}/**/Info.plist

# done
echo "Done."
