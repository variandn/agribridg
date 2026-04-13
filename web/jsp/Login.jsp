<%@ page import="java.sql.*" %>
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
            message = "❌ Username/email and password are required.";
        } else {
            Connection conn = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String dbURL = "jdbc:mysql://localhost:3306/agribridge";
                String dbUser = "root";
                String dbPass = "variandn4";
                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

                // Validate user
                String sql = "SELECT user_id, user_name, role FROM users WHERE (email = ? OR user_name = ?) AND password = ?";
                pst = conn.prepareStatement(sql);
                pst.setString(1, identifier);
                pst.setString(2, identifier);
                pst.setString(3, password);
                rs = pst.executeQuery();

                if (rs.next()) {
                    userId = rs.getString("user_id");
                    userName = rs.getString("user_name");
                    role = rs.getString("role");

                    // Invalidate old sessions in DB
                    String deactivateSQL = "UPDATE session SET is_active = FALSE WHERE user_id = ?";
                    PreparedStatement deactivateStmt = conn.prepareStatement(deactivateSQL);
                    deactivateStmt.setString(1, userId);
                    deactivateStmt.executeUpdate();
                    deactivateStmt.close();

                    // Invalidate session if exists
                    if (session != null) session.invalidate();

                    // Create new session
                    session = request.getSession(true);
                    String sessionToken = java.util.UUID.randomUUID().toString();

                    session.setAttribute("userId", userId);
                    session.setAttribute("userType", role);
                    session.setAttribute("username", userName);
                    session.setAttribute("sessionToken", sessionToken);
                    session.setAttribute("usernameOrEmail", identifier);

                    // Store new session in DB
                    String insertSessionSQL = "INSERT INTO session (user_id, role, session_token, is_active) VALUES (?, ?, ?, ?)";
                    PreparedStatement sessionStmt = conn.prepareStatement(insertSessionSQL);
                    sessionStmt.setString(1, userId);
                    sessionStmt.setString(2, role);
                    sessionStmt.setString(3, sessionToken);
                    sessionStmt.setBoolean(4, true);
                    sessionStmt.executeUpdate();
                    sessionStmt.close();

                    redirecting = true;
                    
                    
                    if ("buyer".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/buyer/buyer_dashboard.html");//recognised by tomcat
                    //("../buyer/buyer_dashboard.jsp");normakl
                    

                    } else if ("seller".equalsIgnoreCase(role)) {
                    session.setAttribute("seller_id", userId); // Store seller_id as user_id
                    response.sendRedirect (request.getContextPath() + "/seller/seller_home.jsp");
                    //("../seller/seller_home.jsp");
              
                    } else if ("admin".equalsIgnoreCase(role)) {
                     response.sendRedirect(request.getContextPath() + "../admin/dashboard.jsp");

                     } else {
                      message = "⚠️ Unknown role. Contact administrator.";
                   }

                } else {
                
                    message = "❌ Invalid credentials.";
                }

            } catch (Exception e) {
                e.printStackTrace();
                message = "❌ Login error: " + e.getMessage();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (pst != null) pst.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
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
            <p>Don't have an account? <a href="../html/register.html">Register</a></p>
        </div>
    </form>

    <% if (!message.isEmpty()) { %>
        <div class="message"><%= message %></div>
    <% } %>
</div>

</body>
</html>
