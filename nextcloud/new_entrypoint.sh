#!/bin/sh

/cron.sh &
/entrypoint.sh apache2-foreground
