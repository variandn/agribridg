<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.PasswordUtils, Servlets.HtmlUtils" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String message = "";
    boolean redirecting = false;

    String identifier = request.getParameter("username") != null ? request.getParameter("username").trim() : "";
    String password = request.getParameter("password") != null ? request.getParameter("password").trim() : "";

    String userId = null;
    String role = null;
    String userName = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (identifier.isEmpty() || password.isEmpty()) {
            message = "Username/email and password are required.";
        } else {
            try {
                MongoDatabase db = MongoDBConnection.getDatabase();

                // Find user by identifier only (not password)
                MongoCollection<Document> users = db.getCollection("users");
                Document user = users.find(Filters.or(
                    Filters.eq("email", identifier),
                    Filters.eq("user_name", identifier)
                )).first();

                if (user != null) {
                    String storedPassword = user.getString("password");
                    boolean authenticated = false;

                    if (PasswordUtils.isHashed(storedPassword)) {
                        // Password is already hashed — verify against hash
                        authenticated = PasswordUtils.verifyPassword(password, storedPassword);
                    } else {
                        // Legacy plaintext password — verify and migrate to hash
                        if (password.equals(storedPassword)) {
                            authenticated = true;
                            // Migrate: replace plaintext with hash
                            String hashed = PasswordUtils.hashPassword(password);
                            users.updateOne(
                                Filters.eq("_id", user.getObjectId("_id")),
                                Updates.set("password", hashed)
                            );
                        }
                    }

                    if (authenticated) {
                        userId = user.getObjectId("_id").toHexString();
                        userName = user.getString("user_name");
                        role = user.getString("role");

                        // Invalidate old sessions in DB
                        MongoCollection<Document> sessions = db.getCollection("sessions");
                        sessions.updateMany(
                            Filters.eq("user_id", userId),
                            Updates.set("is_active", false)
                        );

                        // Invalidate HTTP session if exists
                        if (session != null) session.invalidate();

                        // Create new HTTP session
                        session = request.getSession(true);
                        String sessionToken = java.util.UUID.randomUUID().toString();

                        session.setAttribute("userId", userId);
                        session.setAttribute("userType", role);
                        session.setAttribute("username", userName);
                        session.setAttribute("sessionToken", sessionToken);
                        session.setAttribute("usernameOrEmail", identifier);

                        // Store new session in MongoDB
                        Document sessionDoc = new Document("user_id", userId)
                                .append("role", role)
                                .append("session_token", sessionToken)
                                .append("is_active", true)
                                .append("login_time", new java.util.Date());
                        sessions.insertOne(sessionDoc);

                        redirecting = true;

                        if ("buyer".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/buyer/buyer_dashboard.html");
                        } else if ("seller".equalsIgnoreCase(role)) {
                            session.setAttribute("seller_id", userId);
                            response.sendRedirect(request.getContextPath() + "/seller/seller_home.jsp");
                        } else if ("admin".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                        } else {
                            message = "Unknown role. Contact administrator.";
                        }
                    } else {
                        message = "Invalid credentials.";
                    }
                } else {
                    message = "Invalid credentials.";
                }

            } catch (Exception e) {
                e.printStackTrace();
                message = "A login error occurred. Please try again later.";
            }
        }
    }

    if (redirecting) return;
%>

<!DOCTYPE html>
<html>
<head>
    <title>AgriBridge Login</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(to right, #2ecc71, #27ae60);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .login-container {
            background-color: white;
            padding: 2.5rem;
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
            max-width: 400px;
            width: 100%;
        }

        .login-container h2 {
            text-align: center;
            margin-bottom: 1.5rem;
            color: #2c3e50;
        }

        .form-group {
            margin-bottom: 1.2rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #333;
        }

        .form-group input {
            width: 100%;
            padding: 0.6rem;
            border-radius: 8px;
            border: 1px solid #ccc;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-group input:focus {
            border-color: #27ae60;
            outline: none;
        }

        .btn {
            width: 100%;
            padding: 0.75rem;
            background-color: #27ae60;
            color: white;
            font-size: 1rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s, transform 0.2s;
        }

        .btn:hover {
            background-color: #219150;
            transform: translateY(-2px);
        }

        .form-footer {
            text-align: center;
            margin-top: 1rem;
        }

        .form-footer a {
            color: #27ae60;
            text-decoration: none;
            font-size: 0.95rem;
        }

        .form-footer a:hover {
            text-decoration: underline;
        }

        .message {
            text-align: center;
            color: red;
            margin-top: 15px;
        }
    </style>
</head>
<body>

<div class="login-container">
    <h2>Login to AgriBridge</h2>
    <form method="post">
        <div class="form-group">
            <label for="username">Username or Email</label>
            <input type="text" id="username" name="username" required />
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" required />
        </div>

        <button type="submit" class="btn">Login</button>

        <div class="form-footer">
            <p>Don't have an account? <a href="register.jsp">Register</a></p>
        </div>
    </form>

    <% if (!message.isEmpty()) { %>
        <div class="message"><%= HtmlUtils.escape(message) %></div>
    <% } %>
</div>

</body>
</html>
