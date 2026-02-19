# Hydro Smart AI Backend

This is the Python Flash backend for the Hydro Smart application. It provides crop recommendations and analysis.

## Setup

1.  **Install Python 3.9+**
2.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```
3.  **Run Locally**:
    ```bash
    python app.py
    ```
    The server will start at `http://localhost:8080`.

## Deployment (Render.com)

1.  Create a **New Web Service** on [Render](https://render.com).
2.  Connect your GitHub repository.
3.  Select the `backend` directory as the **Root Directory**.
4.  Render will automatically detect the `Dockerfile` and build it.
5.  Once deployed, copy the **onrender.com URL**.

## Update Flutter App

1.  Open `lib/data/repositories/recommendation_repository_impl.dart`.
2.  Update `_baseUrl` with your new deployment URL:
    ```dart
    static const String _baseUrl = 'https://your-app-name.onrender.com/api/v1';
    ```
