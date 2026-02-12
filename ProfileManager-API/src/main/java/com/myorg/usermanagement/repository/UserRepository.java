package com.myorg.usermanagement.repository;

import com.myorg.usermanagement.model.entity.UserEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Repository for user data access.
 * Requirements: Req 2, 5, 6, 9, 10, 15, 23
 */
public class UserRepository {
    
    private static final Logger log = LoggerFactory.getLogger(UserRepository.class);
    
    private final Connection connection;
    
    public UserRepository(Connection connection) {
        this.connection = connection;
    }
    
    /**
     * Finds a user by ID with preferences.
     * Requirement: Req 15, 16 - View Profile Page, Display Profile Fields
     * 
     * @param userId the user ID
     * @return optional user entity
     */
    public Optional<UserEntity> findByIdWithPreferences(Long userId) {
        String sql = "SELECT id, title, first_name, last_name, gender, age, email, address, " +
                     "created_at, updated_at FROM users WHERE id = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    UserEntity user = mapResultSetToEntity(rs);
                    log.info("Found user with ID: {}", userId);
                    return Optional.of(user);
                }
            }
        } catch (SQLException e) {
            log.error("Error finding user by ID: {}", userId, e);
        }
        
        return Optional.empty();
    }
    
    /**
     * Gets user preferences.
     * Requirement: Req 22 - Preferences Selection
     * 
     * @param userId the user ID
     * @return list of preferences
     */
    public List<String> getUserPreferences(Long userId) {
        List<String> preferences = new ArrayList<>();
        String sql = "SELECT preference FROM user_preferences WHERE user_id = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    preferences.add(rs.getString("preference"));
                }
            }
            
            log.info("Found {} preferences for user ID: {}", preferences.size(), userId);
        } catch (SQLException e) {
            log.error("Error getting user preferences for user ID: {}", userId, e);
        }
        
        return preferences;
    }
    
    /**
     * Updates user profile.
     * Requirement: Req 23 - Save Profile
     * 
     * @param user the user entity to update
     * @return true if successful
     */
    public boolean updateProfile(UserEntity user) {
        String sql = "UPDATE users SET title = ?, first_name = ?, last_name = ?, gender = ?, " +
                     "age = ?, email = ?, address = ?, updated_at = CURRENT_TIMESTAMP " +
                     "WHERE id = ?";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, user.getTitle());
            stmt.setString(2, user.getFirstName());
            stmt.setString(3, user.getLastName());
            stmt.setString(4, user.getGender());
            
            if (user.getAge() != null) {
                stmt.setInt(5, user.getAge());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            
            stmt.setString(6, user.getEmail());
            stmt.setString(7, user.getAddress());
            stmt.setLong(8, user.getId());
            
            int rowsAffected = stmt.executeUpdate();
            log.info("Updated profile for user ID: {}, rows affected: {}", user.getId(), rowsAffected);
            
            return rowsAffected > 0;
        } catch (SQLException e) {
            log.error("Error updating profile for user ID: {}", user.getId(), e);
            return false;
        }
    }
    
    /**
     * Updates user preferences.
     * Requirement: Req 22 - Preferences Selection
     * 
     * @param userId the user ID
     * @param preferences the list of preferences
     * @return true if successful
     */
    public boolean updatePreferences(Long userId, List<String> preferences) {
        try {
            // Delete existing preferences
            String deleteSql = "DELETE FROM user_preferences WHERE user_id = ?";
            try (PreparedStatement stmt = connection.prepareStatement(deleteSql)) {
                stmt.setLong(1, userId);
                stmt.executeUpdate();
            }
            
            // Insert new preferences
            String insertSql = "INSERT INTO user_preferences (user_id, preference) VALUES (?, ?)";
            try (PreparedStatement stmt = connection.prepareStatement(insertSql)) {
                for (String preference : preferences) {
                    stmt.setLong(1, userId);
                    stmt.setString(2, preference);
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
            
            log.info("Updated {} preferences for user ID: {}", preferences.size(), userId);
            return true;
        } catch (SQLException e) {
            log.error("Error updating preferences for user ID: {}", userId, e);
            return false;
        }
    }
    
    /**
     * Maps ResultSet to UserEntity.
     * 
     * @param rs the result set
     * @return user entity
     * @throws SQLException if mapping fails
     */
    private UserEntity mapResultSetToEntity(ResultSet rs) throws SQLException {
        UserEntity user = new UserEntity();
        user.setId(rs.getLong("id"));
        user.setTitle(rs.getString("title"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setGender(rs.getString("gender"));
        
        int age = rs.getInt("age");
        if (!rs.wasNull()) {
            user.setAge(age);
        }
        
        user.setEmail(rs.getString("email"));
        user.setAddress(rs.getString("address"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            user.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            user.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return user;
    }
}
