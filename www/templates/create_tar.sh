#!/bin/bash
rm ./templates.tar.gz
tar --exclude=*.less --exclude="_source" -czf ./templates.tar.gz ./_fonts/ ./Light/ ./mobile/ ./Wasp/ ./MoLight/ ./Modern/ ./"Urban Sunrise"/