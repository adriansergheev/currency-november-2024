# Marshall - Cryptocurrency Price Tracker

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)

An cryptocurrency iOS app built with modern SwiftUI using WazirX API for cryptocurrency data and Frankfurter API for exchange rates. 

## Getting Started
```bash
git clone https://github.com/username/marshall.git
cd marshall
xed .
```
The app entry point is marshallApp.swift.

The main UI flow starts with ListView showing a list of cryptocurrencies, with navigation to DetailView for specific pairs and StatusView for system status.

## Key Features
- 💱 Multiple currency support (USD, INR, SEK)
- 🔄 System status monitoring
- 🧪 Unit Tests
- 🧑‍🧑‍🧒‍🧒 Modularization + App Previews

## Architecture
```
modules/
├── ApiClient        # API interface
├── ApiClientLive    # API implementation
├── DetailFeature    # Detail view
├── ListFeature      # Main listing view
├── Model            # Data models
├── StatusFeature    # System monitoring
└── Styleguide       # UI 
```