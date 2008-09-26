#!/bin/sh

# make swf
cd flex
ant
cd ../

# make war
mvn clean
mvn package

# make tar
cp target/*.war dist/twitcaffe/
cd dist/
rm twitcaffe_a3.tar.bz2
tar cfvj twitcaffe_a3.tar.bz2 twitcaffe/
