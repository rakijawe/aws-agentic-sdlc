package com.myorg.usermanagement.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class for database connections.
 * Handles connection creation with RDS Proxy support.
 */
public class DatabaseUtil {
    
    private static final Logger log = LoggerFactory.getLogger(DatabaseUtil.class);
    
    private static final String DB_URL = System.getenv("DB_URL");
    private static final String DB_USER = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");
    
    /**
     * Creates a database connection.
     * 
     * @return database connection
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            log.info("Creating database connection");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            conn.setAutoCommit(false); // Use transactions
            return conn;
        } catch (SQLException e) {
            log.error("Failed to create database connection", e);
            throw e;
        }
    }
    
    /**
     * Closes a database connection safely.
     * 
     * @param conn the connection to close
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                log.info("Database connection closed");
            } catch (SQLException e) {
                log.error("Error closing database connection", e);
            }
        }
    }
    
    /**
     * Commits a transaction.
     * 
     * @param conn the connection
     */
    public static void commit(Connection conn) {
        if (conn != null) {
            try {
                conn.commit();
                log.info("Transaction committed");
            } catch (SQLException e) {
                log.error("Error committing transaction", e);
            }
        }
    }
    
    /**
     * Rolls back a transaction.
     * 
     * @param conn the connection
     */
    public static void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
                log.info("Transaction rolled back");
            } catch (SQLException e) {
                log.error("Error rolling back transaction", e);
            }
        }
    }
}
