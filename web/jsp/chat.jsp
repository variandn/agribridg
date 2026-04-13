<%@ page import="java.sql.*, jakarta.servlet.*, jakarta.servlet.http.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    //HttpSession session = request.getSession(false);
    Integer senderId = (session != null) ? (Integer) session.getAttribute("userId") : null;

    if (senderId == null) {
        response.sendRedirect("Login.jsp?message=Please login to chat.");
        return;
    }

    String supplierIdStr = request.getParameter("id");
    String productIdStr = request.getParameter("productId");

    int supplierId = Integer.parseInt(supplierIdStr);
    int productId = Integer.parseInt(productIdStr);

    // Handle message submission
    String message = request.getParameter("message");
    if (message != null && !message.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");

            PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO chats (sender_id, receiver_id, product_id, message) VALUES (?, ?, ?, ?)");
            insertStmt.setInt(1, senderId);
            insertStmt.setInt(2, supplierId);
            insertStmt.setInt(3, productId);
            insertStmt.setString(4, message);
            insertStmt.executeUpdate();

            conn.close();
        } catch (Exception e) {
            out.println("Error sending message: " + e.getMessage());
        }
    }

    // Load chat history
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/agribridge", "root", "variandn4");

        stmt = conn.prepareStatement(
            "SELECT * FROM messages WHERE product_id = ? AND " +
            "((sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)) " +
            "ORDER BY timestamp ASC"
        );
        stmt.setInt(1, productId);
        stmt.setInt(2, senderId);
        stmt.setInt(3, supplierId);
        stmt.setInt(4, supplierId);
        stmt.setInt(5, senderId);

        rs = stmt.executeQuery();
%>

<html>
<head>
    <title>Chat with Supplier</title>
    <style>
        .chat-box {
            max-width: 600px;
            margin: auto;
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
        }
        .message {
            margin-bottom: 10px;
        }
        .sender {
            font-weight: bold;
            color: #007bff;
        }
        .receiver {
            font-weight: bold;
            color: #28a745;
        }
        .chat-form {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }
        textarea {
            width: 100%;
            height: 60px;
            padding: 10px;
        }
        button {
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<div class="chat-box">
    <h2>Chat with Supplier</h2>

    <% while (rs.next()) {
        int sender = rs.getInt("sender_id");
        String msg = rs.getString("message");
    %>
        <div class="message">
            <span class="<%= (sender == senderId) ? "sender" : "receiver" %>">
                <%= (sender == senderId) ? "You" : "Supplier" %>:
            </span>
            <span><%= msg %></span>
        </div>
    <% } %>

    <!-- Message form -->
    <form method="post" class="chat-form">
        <textarea name="message" placeholder="Type your message here..." required></textarea>
        <input type="hidden" name="supplierId" value="<%= supplierId %>" />
        <input type="hidden" name="productId" value="<%= productId %>" />
        <button type="submit">Send</button>
    </form>
</div>
</body>
</html>

<%
    conn.close();
    } catch (Exception e) {
        out.println("Error loading messages: " + e.getMessage());
    }
%>
