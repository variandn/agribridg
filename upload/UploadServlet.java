package com.upload;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/UploadServlet")
@MultipartConfig // Annotation to indicate that the servlet handles file uploads
public class UploadServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/yourDatabase"; // Update your database name
    private static final String DB_USER = "yourUsername"; // Update with your DB username
    private static final String DB_PASSWORD = "yourPassword"; // Update with your DB password

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String model = request.getParameter("model");
        String fuelType = request.getParameter("fuel_type");
        Part filePart = request.getPart("photo"); // Retrieves <input type="file" name="photo">
        
        if (filePart != null && model != null && fuelType != null) {
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                String sql = "INSERT INTO car_photos (model, fuel_type, photo) VALUES (?, ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setString(1, model);
                    statement.setString(2, fuelType);

                    // Get the input stream of the file
                    InputStream inputStream = filePart.getInputStream();
                    statement.setBlob(3, inputStream);

                    // Execute the insert
                    int row = statement.executeUpdate();
                    if (row > 0) {
                        response.getWriter().println("Image uploaded successfully!");
                    } else {
                        response.getWriter().println("Image upload failed!");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().println("Error occurred while uploading: " + e.getMessage());
            }
        } else {
            response.getWriter().println("Please provide all required fields.");
        }
    }
}
