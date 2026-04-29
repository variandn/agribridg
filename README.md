# AgriBridge 🌾

An agricultural marketplace web application connecting farmers, buyers, and sellers across the world. Built with Java EE (Jakarta Servlet/JSP) on Apache Tomcat, backed by MongoDB Atlas.

## Features

- **Buyer Dashboard** — Browse and search agricultural products
- **Seller Dashboard** — Upload, manage, and track product inventory
- **Real-time Chat** — Buyers can contact suppliers directly
- **Session Management** — Secure login with server-side session validation
- **Image Handling** — Product images stored as binary in MongoDB

## Tech Stack

| Layer        | Technology                          |
|--------------|-------------------------------------|
| Frontend     | JSP, HTML5, CSS3                    |
| Backend      | Jakarta Servlet 6.0, JSP Scriptlets|
| Database     | MongoDB Atlas (cloud)               |
| Server       | Apache Tomcat 10.1                  |
| Deployment   | Docker → Render                     |
| Java         | JDK 23 (Temurin)                    |

## Prerequisites

- **Java JDK 17+** (tested with JDK 23)
- **Apache Tomcat 10.1+**
- **MongoDB Atlas** account with a cluster
- **NetBeans** (optional, project includes nbproject configs)

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/variandn/agribridg.git
cd agribridg
```

### 2. Set environment variables

The app requires a `MONGODB_URI` environment variable pointing to your MongoDB Atlas cluster.

**Windows (PowerShell):**
```powershell
$env:MONGODB_URI = "mongodb+srv://<user>:<password>@<cluster>.mongodb.net/?retryWrites=true&w=majority&appName=Agribridg"
```

**Linux/Mac:**
```bash
export MONGODB_URI="mongodb+srv://<user>:<password>@<cluster>.mongodb.net/?retryWrites=true&w=majority&appName=Agribridg"
```

**NetBeans:** Add the variable in Project Properties → Run → VM Options:
```
-DMONGODB_URI=mongodb+srv://...
```

### 3. Deploy to Tomcat

- Open in NetBeans and run, **or**
- Use `ant` to build: `ant clean build` then deploy the WAR to Tomcat

### 4. Access the app

Navigate to `http://localhost:8080/` — the welcome page is `jsp/home.jsp`.

## Docker Deployment

```bash
docker build -t agribridg .
docker run -p 8080:8080 -e MONGODB_URI="your_connection_string" agribridg
```

### Deploy to Render

1. Push to GitHub
2. Create a new **Web Service** on Render
3. Connect the GitHub repo
4. Set environment variable: `MONGODB_URI` = your Atlas connection string
5. Render will auto-detect the Dockerfile and deploy

## Project Structure

```
agribridg/
├── src/java/Servlets/       # Java servlets and utilities
│   ├── MongoDBConnection.java   # MongoDB Atlas connection singleton
│   ├── UploadProductServlet.java
│   ├── ImageServlet.java
│   ├── PasswordUtils.java       # PBKDF2 password hashing
│   └── HtmlUtils.java           # XSS prevention utility
├── web/
│   ├── WEB-INF/
│   │   ├── web.xml              # Servlet mappings
│   │   └── lib/                 # MongoDB driver JARs
│   ├── jsp/                     # Public pages (login, register, home, etc.)
│   ├── seller/                  # Seller dashboard pages
│   ├── buyer/                   # Buyer dashboard
│   ├── css/                     # Stylesheets
│   └── assets/                  # Static assets
├── Dockerfile                   # Docker build config for Render
└── .gitignore
```

## License

This project is for educational purposes.
