<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page import="jakarta.servlet.*, jakarta.servlet.http.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String senderId = (session != null) ? (String) session.getAttribute("userId") : null;

    if (senderId == null) {
        response.sendRedirect("Login.jsp?message=Please login to chat.");
        return;
    }

    String supplierIdStr = request.getParameter("id");
    String productIdStr = request.getParameter("productId");

    // Handle message submission
    String message = request.getParameter("message");
    if (message != null && !message.trim().isEmpty()) {
        try {
            MongoDatabase db = MongoDBConnection.getDatabase();
            MongoCollection<Document> messages = db.getCollection("messages");

            Document msgDoc = new Document("sender_id", senderId)
                    .append("receiver_id", supplierIdStr)
                    .append("product_id", productIdStr)
                    .append("message", message)
                    .append("timestamp", new java.util.Date());
            messages.insertOne(msgDoc);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Load chat history
    try {
        MongoDatabase db = MongoDBConnection.getDatabase();
        MongoCollection<Document> messagesCol = db.getCollection("messages");

        FindIterable<Document> chatHistory = messagesCol.find(
            Filters.and(
                Filters.eq("product_id", productIdStr),
                Filters.or(
                    Filters.and(Filters.eq("sender_id", senderId), Filters.eq("receiver_id", supplierIdStr)),
                    Filters.and(Filters.eq("sender_id", supplierIdStr), Filters.eq("receiver_id", senderId))
                )
            )
        ).sort(Sorts.ascending("timestamp"));
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

    <% for (Document doc : chatHistory) {
        String sender = doc.getString("sender_id");
        String msg = doc.getString("message");
    %>
        <div class="message">
            <span class="<%= (sender.equals(senderId)) ? "sender" : "receiver" %>">
                <%= (sender.equals(senderId)) ? "You" : "Supplier" %>:
            </span>
            <span><%= HtmlUtils.escape(msg) %></span>
        </div>
    <% } %>

    <!-- Message form -->
    <form method="post" class="chat-form">
        <textarea name="message" placeholder="Type your message here..." required></textarea>
        <input type="hidden" name="id" value="<%= HtmlUtils.escape(supplierIdStr) %>" />
        <input type="hidden" name="productId" value="<%= HtmlUtils.escape(productIdStr) %>" />
        <button type="submit">Send</button>
    </form>
</div>
</body>
</html>

<%
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>Error loading messages. Please try again later.</p>");
    }
%>
