#!/bin/sh -l
if [ "$INPUT_ACTION" == "close" ]; then
     dotnet StaticSitesClient.dll $INPUT_ACTION
     exit 0
 fi

SHOULD_BUILD_FUNCTION=true

cd $GITHUB_WORKSPACE

if [ ! -d "$INPUT_APP_SOURCE_LOCATION" ]; then
    echo "\e[31mCould not find application source folder: $INPUT_APP_SOURCE_LOCATION\e[0m"
    exit 1
fi

if [ ! -d "$INPUT_API_SOURCE_LOCATION" ]; then
    SHOULD_BUILD_FUNCTION=false
    echo "\e[33mCould not find the azure function source folder: $INPUT_API_SOURCE_LOCATION (This is safe to ignore if you are not using Azure Functions)\e[0m"
    exit 1
fi

# Build App Folder
echo "Building app folder"
oryx build $INPUT_APP_SOURCE_LOCATION -o /github/staticsitesoutput/app
if [ 0 -eq $? ]; then
    echo "\e[32mSuccessfully built app folder\e[0m"
else
    echo "\e[31mFailed to build application\e[0m"
    exit 1
fi;

# Build and Zip Api Folder
if [ SHOULD_BUILD_FUNCTION ]; then
    cd $GITHUB_WORKSPACE
    echo "Building api folder"
    oryx build $INPUT_API_SOURCE_LOCATION -o /github/staticsitesoutput/api
    if [ 0 -eq $? ]; then
        echo "\e[32mSuccessfully built api folder\e[0m"
    else
        echo "\e[31mFailed to build api folder\e[0m"
        exit 1
    fi;
fi

cd /bin/staticsites/

if [ SHOULD_BUILD_FUNCTION ]; then
     dotnet StaticSitesClient.dll $INPUT_ACTION --app="/github/staticsitesoutput/app/$INPUT_APP_ARTIFACT_LOCATION" --api="/github/staticsitesoutput/api/$INPUT_APP_BUILD_OUTPUT_LOCATION"
else
     dotnet StaticSitesClient.dll $INPUT_ACTION --app="/github/staticsitesoutput/app/$INPUT_APP_ARTIFACT_LOCATION"
fi;
