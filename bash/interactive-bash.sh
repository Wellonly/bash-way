#!/bin/bash
read -p "Enter y if everything is ok:" isok
[ "$isok" == "y" ] && echo "..o yes: y" || echo "..entered: $isok"
