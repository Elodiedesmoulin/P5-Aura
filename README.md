# 🌤 Aura – Simple Bank App (Project P5)

<img width="300" alt="Aura Bank App" src="![image](https://github.com/user-attachments/assets/2636fc06-9f7e-4811-a178-4bcc679f0fc8)">

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

**Aura** is a simple and modern banking app prototype built with **SwiftUI**.  
It was developed as part of the **iOS Developer path (Project 5)** at OpenClassrooms.  
The goal was to consume data from an external REST API, manage data display using MVVM architecture, and create a responsive and dynamic mobile interface.

---

### Features

- **Displays a list of banking transactions** retrieved from an API
- **Detailed transaction view** for each item
- **Clean, scrollable interface** built with SwiftUI
- **Static authentication view**
- **Data loaded asynchronously with decoding from JSON**

---

### Architecture

The app follows a simple **MVVM architecture**:

#### View
Handles user interface using SwiftUI components.

#### ViewModel
Fetches and prepares data for the views. Implements business logic and formats raw model data.

#### Model
Contains the transaction data structure (`Transaction`) and handles JSON decoding using `Codable`.

---

## Getting Started

### Prerequisites

- Xcode 15 or later
- iOS 17 or later

---

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/Aura-BankingApp.git
