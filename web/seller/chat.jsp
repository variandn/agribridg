<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.HtmlUtils" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="auth_check.jsp" %>
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
    String supportId = "support"; // Use "support" as the support ID

    // Handle new message submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String msg = request.getParameter("message");

        if (msg != null && !msg.trim().isEmpty()) {
            try {
                MongoDatabase db = MongoDBConnection.getDatabase();
                MongoCollection<Document> messages = db.getCollection("messages");

                Document msgDoc = new Document("sender_id", sellerId)
                        .append("receiver_id", supportId)
                        .append("message", msg)
                        .append("sent_at", new java.util.Date());
                messages.insertOne(msgDoc);
            } catch(Exception e) {
                e.printStackTrace();
%>
                <p style="color:red;">Error sending message. Please try again.</p>
<%
            }
        }
    }

    // Fetch message history
    try {
        MongoDatabase db = MongoDBConnection.getDatabase();
        MongoCollection<Document> messagesCol = db.getCollection("messages");

        FindIterable<Document> chatHistory = messagesCol.find(
            Filters.or(
                Filters.and(Filters.eq("sender_id", sellerId), Filters.eq("receiver_id", supportId)),
                Filters.and(Filters.eq("sender_id", supportId), Filters.eq("receiver_id", sellerId))
            )
        ).sort(Sorts.ascending("sent_at"));

        for (Document doc : chatHistory) {
            boolean isSender = sellerId.equals(doc.getString("sender_id"));
%>
            <div class="message <%= isSender ? "sent" : "received" %>">
                <strong><%= isSender ? "You" : "Support" %>:</strong>
                <%= HtmlUtils.escape(doc.getString("message")) %> <br>
                <small><%= doc.getDate("sent_at") %></small>
            </div>
<%
        }
    } catch(Exception e) {
        e.printStackTrace();
%>
        <p style="color:red;">Error loading messages. Please try again later.</p>
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
