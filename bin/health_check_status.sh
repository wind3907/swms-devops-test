#!/bin/bash

response=$(curl -s $1)
status=($(echo $response | cut -d ":"  -f 2 | cut -d "}" -f 1 | cut -d '"' -f 2))
echo $status