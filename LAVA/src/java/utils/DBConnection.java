/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static final String SERVER;
    private static final String PORT;
    private static final String DATABASE;
    private static final String USERNAME;
    private static final String PASSWORD;
    private static final String URL;

    static {
        Properties props = new Properties();
        try (InputStream in = DBConnection.class.getResourceAsStream("/db.properties")) {
            if (in == null) {
                throw new RuntimeException(
                        "Missing db.properties on classpath. Copy src/java/db.properties.example "
                        + "to src/java/db.properties and fill in your local DB credentials.");
            }
            props.load(in);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load db.properties", e);
        }

        SERVER = props.getProperty("db.server", "localhost");
        PORT = props.getProperty("db.port", "1433");
        DATABASE = props.getProperty("db.name", "EcommerceDB");
        USERNAME = props.getProperty("db.user");
        PASSWORD = props.getProperty("db.password");

        URL = "jdbc:sqlserver://" + SERVER + ":" + PORT
                + ";databaseName=" + DATABASE
                + ";encrypt=true"
                + ";trustServerCertificate=true";

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("Not found SQL Server JDBC Driver!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    // ── Test kết nối (chạy main để kiểm tra) ──────────────────────────────
    public static void main(String[] args) {
        System.out.println("Connecting to SQL Server...");
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("Connect successful! Database: " + DATABASE);
            }
        } catch (SQLException e) {
            System.err.println("Connect failed" + e.getMessage());
            e.printStackTrace();
        }
    }
}
