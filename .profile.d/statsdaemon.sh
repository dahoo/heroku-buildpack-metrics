#!/bin/bash

statsdaemon -export-url $HEROKU_METRICS_URL -instance $DYNO &