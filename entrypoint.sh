#!/bin/bash
set -e

# Entrypoint script for Depix Docker container
# This allows simpler command syntax

# Default to depix.py if no command specified
if [ $# -eq 0 ]; then
    exec python3 depix.py -h
fi

# Check if first argument is a tool name
case "$1" in
    depix)
        shift
        exec python3 depix.py "$@"
        ;;
    show-boxes)
        shift
        exec python3 tool_show_boxes.py "$@"
        ;;
    gen-pixelated)
        shift
        exec python3 tool_gen_pixelated.py "$@"
        ;;
    *)
        # If it starts with -, assume it's depix arguments
        if [[ "$1" == -* ]]; then
            exec python3 depix.py "$@"
        else
            # Otherwise, execute as-is (for custom commands)
            exec "$@"
        fi
        ;;
esac
