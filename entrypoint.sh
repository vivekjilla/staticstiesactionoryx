#!/bin/sh -l
cd /bin/staticsites/
dotnet StaticSitesClient.dll $INPUT_ACTION --oryxEnabled true
