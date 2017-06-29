#!/bin/bash
hugo
# Deploy to surge
surge --project ./public/ --domain devserge.surge.sh