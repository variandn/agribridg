<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.*" %>
<%@ page import="jakarta.servlet.http.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>User Registration</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f3f6f9;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 50%;
            margin: 40px auto;
            padding: 25px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        input, select {
            width: 100%;
            padding: 10px;
            margin: 6px 0 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        button {
            padding: 12px 20px;
            background-color: #28a745;
            border: none;
            color: #fff;
            border-radius: 5px;
            cursor: pointer;
        }
        h2 {
            text-align: center;
            margin-bottom: 25px;
        }
        .message {
            text-align: center;
            font-size: 16px;
            margin-top: 15px;
        }
        .message.success {
            color: green;
        }
        .message.error {
            color: red;
        }
    </style>
</head>
<body>

<%
    String message = "";
    boolean registrationSuccess = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String role = request.getParameter("userType");
        String firstname = request.getParameter("firstname");
        String lastname = request.getParameter("lastname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String country = request.getParameter("country");
        String password = request.getParameter("password");
        String confirmpassword = request.getParameter("confirm_password");

        String dbURL = "jdbc:mysql://localhost:3306/agribridge";
        String dbUser = "root";
        String dbPass = "variandn4";

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            if (username != null && email != null && password != null && password.equals(confirmpassword)) {
                String sql = "INSERT INTO users (role, user_name, first_name, last_name, email, phone, gender, address, country, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, role);
                stmt.setString(2, username);
                stmt.setString(3, firstname);
                stmt.setString(4, lastname);
                stmt.setString(5, email);
                stmt.setString(6, phone);
                stmt.setString(7, gender);
                stmt.setString(8, address);
                stmt.setString(9, country);
                stmt.setString(10, password);

                int rows = stmt.executeUpdate();
                if (rows > 0) {
                    registrationSuccess = true;
                    message = "Registration successful!";
                } else {
                    message = "<div class='message error'>❌ Registration failed. Please try again.</div>";
                }
            } else {
                message = "<div class='message error'>⚠️ All fields are required and passwords must match.</div>";
            }
        } catch (SQLException e) {
            if (e.getMessage().contains("Duplicate entry") && e.getMessage().contains("User_name_UNIQUE")) {
                message = "<div class='message error'>❌ Username already exists. Please choose a different one.</div>";
            } else if (e.getMessage().contains("Duplicate entry") && e.getMessage().contains("email")) {
                message = "<div class='message error'>❌ This email is already registered. Try logging in or use another email.</div>";
            } else {
                message = "<div class='message error'>❌ Database error: " + e.getMessage() + "</div>";
            }
        } catch (ClassNotFoundException e) {
            message = "<div class='message error'>❌ JDBC Driver not found. Please check your server setup.</div>";
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
%>

<div class="container">
    <h2>User Registration</h2>

    <form method="post" action="register.jsp">
        <label for="userType">User Type:</label>
        <select name="userType" required>
            <option value="">-- Select Role --</option>
            <option value="buyer">Buyer</option>
            <option value="seller">Seller</option>
        </select>

        <input type="text" name="username" placeholder="Username" required />
        <input type="text" name="firstname" placeholder="First Name" required />
        <input type="text" name="lastname" placeholder="Last Name" required />
        <input type="email" name="email" placeholder="Email" required />
        <input type="text" name="phone" placeholder="Phone Number" required />
        
        <label for="gender">Gender:</label>
        <select name="gender" required>
            <option value="">-- Select Gender --</option>
            <option value="male">Male</option>
            <option value="female">Female</option>
        </select>

        <input type="text" name="address" placeholder="Address" required />
       <!-- <input type="text" name="country" placeholder="Country" required />-->
        <label for="country">Country</label>
        <select id="country" name="country" required>
            <option value="">-- Select Country --</option>
             <option value="kenya">Uganda</option>
            <option value="kenya">Kenya</option>
            <option value="nigeria">Nigeria</option>
            <option value="india">India</option>
            <option value="uk">United Kingdom</option>
            <option value="usa">United States</option>
            <option value="other">Other</option>
        </select>
        <input type="password" name="password" placeholder="Password" required />
        <input type="password" name="confirm_password" placeholder="Confirm Password" required />

        <button type="submit">Register</button>
    </form>

    <%= message %>
</div>

<% if (registrationSuccess) { %>
<script>
    const popup = window.open("", "RegistrationSuccess", "width=400,height=200");
    popup.document.write(`
        <html>
        <head><title>Success</title></head>
        <body style='font-family: Arial; text-align: center; padding-top: 50px;'>
            <h3 style='color: green;'>✅ Registration Successful!</h3>
            <p>You will be redirected to login shortly...</p>
        </body>
        </html>
    `);
    setTimeout(() => {
        window.location.href = '../jsp/Login.jsp';
    }, 3000); // Redirect in 3 seconds
</script>
<% } %>

</body>
</html>
