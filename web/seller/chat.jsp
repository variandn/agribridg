<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="navbar.jsp" %>
<html>
<head>
    <title>Chat Support</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f2f9f4;
        }
        .chat-container {
            width: 80%;
            margin: 30px auto;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 0 10px #ccc;
            padding: 20px;
        }
        .message {
            margin: 10px 0;
            padding: 10px;
            border-radius: 8px;
            max-width: 60%;
        }
        .sent {
            background-color: #d1ffd6;
            align-self: flex-end;
        }
        .received {
            background-color: #eee;
        }
        .form-container {
            margin-top: 20px;
        }
        input[type="text"], textarea {
            width: 100%;
            padding: 10px;
            margin-top: 8px;
            border-radius: 5px;
            border: 1px solid #aaa;
        }
        input[type="submit"] {
            margin-top: 10px;
            padding: 10px 20px;
            background-color: #2e8b57;
            color: white;
            border: none;
            font-weight: bold;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #266c44;
        }
    </style>
</head>
<body>

<div class="chat-container">
    <h2>Chat with Support</h2>

<%
    int sellerId = 1; // Simulated seller ID
    int supportId = 0; // We'll use 0 for system support

    // Handle new message submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String msg = request.getParameter("message");

        if (msg != null && !msg.trim().isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_ride", "root", "yourpassword");

                PreparedStatement ps = con.prepareStatement("INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)");
                ps.setInt(1, sellerId);
                ps.setInt(2, supportId);
                ps.setString(3, msg);
                ps.executeUpdate();

                ps.close();
                con.close();
            } catch(Exception e) {
%>
                <p style="color:red;">Error: <%= e.getMessage() %></p>
<%
            }
        }
    }

    // Fetch message history
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/agri_ride", "root", "yourpassword");

        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM messages WHERE (sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?) ORDER BY sent_at ASC"
        );
        ps.setInt(1, sellerId);
        ps.setInt(2, supportId);
        ps.setInt(3, supportId);
        ps.setInt(4, sellerId);
        ResultSet rs = ps.executeQuery();

        while(rs.next()) {
            boolean isSender = rs.getInt("sender_id") == sellerId;
%>
            <div class="message <%= isSender ? "sent" : "received" %>">
                <strong><%= isSender ? "You" : "Support" %>:</strong>
                <%= rs.getString("message") %> <br>
                <small><%= rs.getTimestamp("sent_at") %></small>
            </div>
<%
        }

        rs.close();
        ps.close();
        con.close();
    } catch(Exception e) {
%>
        <p style="color:red;">Error: <%= e.getMessage() %></p>
<%
    }
%>

    <div class="form-container">
        <form method="post">
            <label>Type your message:</label>
            <textarea name="message" required></textarea>
            <input type="submit" value="Send Message">
        </form>
    </div>
</div>

</body>
</html>

