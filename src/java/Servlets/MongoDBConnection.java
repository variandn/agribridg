package Servlets;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.IndexOptions;
import com.mongodb.client.model.Indexes;

/**
 * Centralized MongoDB Atlas connection utility.
 * 
 * On Render/production: Set the MONGODB_URI environment variable.
 * Locally: Falls back to the hardcoded connection string below.
 */
public class MongoDBConnection {

    private static final String DATABASE_NAME = "agribridge";

    private static MongoClient mongoClient = null;
    private static boolean indexesCreated = false;

    /**
     * Get the MongoDB database instance.
     * Creates the connection on first call (singleton pattern).
     */
    public static synchronized MongoDatabase getDatabase() {
        if (mongoClient == null) {
            String connStr = System.getenv("MONGODB_URI");
            if (connStr == null || connStr.isEmpty()) {
                System.out.println("MONGODB_URI environment variable is not set. Falling back to local MongoDB instance.");
                connStr = "mongodb://localhost:27017";
            }
            // Debug: log that we're connecting (mask the password)
            String masked = connStr.replaceAll("://([^:]+):([^@]+)@", "://$1:****@");
            System.out.println("Connecting to MongoDB: " + masked);

            mongoClient = MongoClients.create(connStr);
        }

        MongoDatabase db = mongoClient.getDatabase(DATABASE_NAME);

        // Create unique indexes once (for username and email uniqueness)
        if (!indexesCreated) {
            try {
                db.getCollection("users").createIndex(
                        Indexes.ascending("user_name"),
                        new IndexOptions().unique(true));
                db.getCollection("users").createIndex(
                        Indexes.ascending("email"),
                        new IndexOptions().unique(true));
                indexesCreated = true;
            } catch (Exception e) {
                // Indexes may already exist, that's fine
                indexesCreated = true;
            }
        }

        return db;
    }

    /**
     * Force reconnect on next getDatabase() call.
     * Useful if credentials change or connection fails.
     */
    public static synchronized void reset() {
        if (mongoClient != null) {
            try {
                mongoClient.close();
            } catch (Exception ignored) {
            }
            mongoClient = null;
        }
    }

    /**
     * Close the MongoDB connection (call on app shutdown).
     */
    public static synchronized void close() {
        if (mongoClient != null) {
            mongoClient.close();
            mongoClient = null;
        }
    }
}
