#!/bin/bash
hugo
# Deploy to surge
surge --project ./public/ --domain https://devserge.surge.sh