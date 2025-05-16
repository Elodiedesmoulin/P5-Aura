# 🌤 Aura – Weather Forecast App (Project P5)

<![image](https://github.com/user-attachments/assets/26082658-6672-4abe-9298-fb2c621d53e0)>

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)

---

### Introduction

**Aura** is a minimalist weather forecast app built with **SwiftUI**.  
It was developed as part of the **iOS Developer path (Project 5)** at OpenClassrooms.  
The goal of this project is to fetch external data via a REST API, decode it using Swift, and display it in a clean, interactive mobile UI.

---

### Features

- **API Integration** with OpenWeatherMap to fetch real-time weather data
- **Current weather display**: temperature, icon, location
- **Daily forecast**: upcoming days with min/max temperatures and condition icons
- **JSON parsing** with `Codable` models
- **Modern SwiftUI interface** with adaptive layout

---

### Architecture

The app follows the **MVVM architecture**:

#### View
Displays the user interface using SwiftUI. Handles user interactions.

#### ViewModel
Processes raw data from the API, transforms it into display-friendly information, and handles business logic.

#### Model
Contains the data structures representing weather data, decoded from JSON responses.

---

## Getting Started

### Prerequisites

- Xcode 15 or later
- iOS 17 or later
- Internet connection (for API calls)

---

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/Aura-WeatherApp.git
