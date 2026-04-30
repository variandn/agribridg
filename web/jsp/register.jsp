<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection, com.mongodb.MongoWriteException" %>
<%@ page import="Servlets.PasswordUtils, Servlets.HtmlUtils" %>
<%@ page import="jakarta.servlet.*, jakarta.servlet.http.*" %>
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
            padding: 10px;
            border-radius: 5px;
        }
        .message.success {
            color: white;
            background-color: #28a745;
        }
        .message.error {
            color: white;
            background-color: #dc3545;
        }
    </style>
</head>
<body>

<%
    String message = "";
    String messageClass = "";
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

        try {
            if (username != null && email != null && password != null && password.equals(confirmpassword)) {
                MongoDatabase db = MongoDBConnection.getDatabase();
                MongoCollection<Document> users = db.getCollection("users");

                // Hash the password before storing
                String hashedPassword = PasswordUtils.hashPassword(password);

                Document newUser = new Document("role", role)
                        .append("user_name", username)
                        .append("first_name", firstname)
                        .append("last_name", lastname)
                        .append("email", email)
                        .append("phone", phone)
                        .append("gender", gender)
                        .append("address", address)
                        .append("country", country)
                        .append("password", hashedPassword)
                        .append("created_at", new java.util.Date());

                users.insertOne(newUser);
                registrationSuccess = true;
                message = "Registration successful!";
                messageClass = "success";
            } else {
                message = "All fields are required and passwords must match.";
                messageClass = "error";
            }
        } catch (MongoWriteException e) {
            messageClass = "error";
            if (e.getCode() == 11000) {
                String errorMsg = e.getMessage();
                if (errorMsg.contains("user_name")) {
                    message = "Username already exists. Please choose a different one.";
                } else if (errorMsg.contains("email")) {
                    message = "This email is already registered. Try logging in or use another email.";
                } else {
                    message = "An account with these details already exists.";
                }
            } else {
                message = "A registration error occurred. Please try again later.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            MongoDBConnection.reset();
            String uri = System.getenv("MONGODB_URI");
            String pwdLen = "?";
            if (uri != null && uri.contains(":") && uri.contains("@")) {
                // Extract password between the second ":" and "@"
                int userStart = uri.indexOf("://") + 3;
                int colonPos = uri.indexOf(":", userStart);
                int atPos = uri.indexOf("@", colonPos);
                if (colonPos > 0 && atPos > colonPos) {
                    pwdLen = String.valueOf(atPos - colonPos - 1);
                }
            }
            String masked = (uri != null) ? uri.replaceAll("://([^:]+):([^@]+)@", "://$1:****@") : "NULL";
            message = "DEBUG: " + e.getClass().getSimpleName() + " | PWD_LEN=" + pwdLen + " | URI: " + masked;
            messageClass = "error";
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
        <label for="country">Country</label>
        <select id="country" name="country" required>
            <option value="">-- Select Country --</option>
            <option value="uganda">Uganda</option>
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

    <% if (!message.isEmpty()) { %>
        <div class="message <%= HtmlUtils.escape(messageClass) %>"><%= HtmlUtils.escape(message) %></div>
    <% } %>
</div>

<% if (registrationSuccess) { %>
<script>
    setTimeout(() => {
        window.location.href = 'Login.jsp';
    }, 2000);
</script>
<% } %>

</body>
</html>
