# Wake Word Model Files

This directory contains wake word model files for the Porcupine wake word detection engine.

## Required Files

- `hey_vista_zh.ppn`: Chinese wake word model for "Hey Vista" (嘿，Vista)

## How to Generate Custom Wake Word Models

To generate custom wake word models for Porcupine:

1. Visit the [Picovoice Console](https://console.picovoice.ai/)
2. Create an account and obtain an access key
3. Use the Porcupine wake word creator to generate a custom wake word model
4. Download the generated `.ppn` file and place it in this directory
5. Update the access key in the application code

## Note

The actual wake word model file is not included in this repository. You need to generate your own wake word model file and place it in this directory.
