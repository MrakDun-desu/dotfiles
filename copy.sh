#!/usr/bin/bash

for f in .*
do
    if [ $f != ".git" ]; then
        cp -r $f ~/
    fi
done

