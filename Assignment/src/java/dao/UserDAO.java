/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.User;
import utils.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;

public class UserDAO {

    // ── Tìm user theo username ─────────────────────────────────────────────
    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT u.*, r.role_name FROM users u "
                + "JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.username = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        }
        return null;
    }

    // ── Tìm user theo email ────────────────────────────────────────────────
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.*, r.role_name FROM users u "
                + "JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.email = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        }
        return null;
    }

    // ── Tìm user theo ID ───────────────────────────────────────────────────
    public User findById(int userId) throws SQLException {
        String sql = "SELECT u.*, r.role_name FROM users u "
                + "JOIN roles r ON u.role_id = r.role_id "
                + "WHERE u.user_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        }
        return null;
    }

    // ── Đăng ký user mới ──────────────────────────────────────────────────
    public boolean insert(User user) throws SQLException {
        String sql = "INSERT INTO users (username, password_hash, email, phone, full_name, role_id, is_active) "
                + "VALUES (?, ?, ?, ?, ?, 2, 1)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPasswordHash());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getFullName());
            return ps.executeUpdate() > 0;
        }
    }

    // ── Cập nhật thông tin profile ─────────────────────────────────────────
    public boolean updateProfile(int userId, String fullName, String phone, String email) throws SQLException {
        String sql = "UPDATE users SET full_name=?, phone=?, email=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Đổi mật khẩu ──────────────────────────────────────────────────────
    public boolean updatePassword(int userId, String newHashedPassword) throws SQLException {
        String sql = "UPDATE users SET password_hash=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHashedPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Lưu token reset mật khẩu ──────────────────────────────────────────
    public boolean saveResetToken(int userId, String token, LocalDateTime expireTime) throws SQLException {
        // Xóa token cũ của user này trước
        String deleteSql = "DELETE FROM password_resets WHERE user_id=?";
        String insertSql = "INSERT INTO password_resets (user_id, reset_token, expire_time, is_used) VALUES (?,?,?,0)";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, userId);
                ps.setString(2, token);
                ps.setTimestamp(3, Timestamp.valueOf(expireTime));
                return ps.executeUpdate() > 0;
            }
        }
    }

    // ── Tìm user theo reset token (chưa dùng, chưa hết hạn) ───────────────
    public User findByResetToken(String token) throws SQLException {
        String sql = "SELECT user_id, reset_token, is_used, expire_time "
                + "FROM password_resets WHERE reset_token = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    System.out.println("❌ Token not found in DB at all!");
                    return null;
                }
                System.out.println("Token found:");
                System.out.println("  user_id    = " + rs.getInt("user_id"));
                System.out.println("  is_used    = " + rs.getInt("is_used"));
                System.out.println("  expire_time= " + rs.getTimestamp("expire_time"));

                // Check conditions
                int isUsed = rs.getInt("is_used");
                Timestamp expire = rs.getTimestamp("expire_time");
                Timestamp now = new Timestamp(System.currentTimeMillis());

                System.out.println("  is_used==0? " + (isUsed == 0));
                System.out.println("  not expired? " + expire.after(now));

                if (isUsed != 0 || !expire.after(now)) {
                    System.out.println("❌ Token invalid: used or expired!");
                    return null;
                }

                int userId = rs.getInt("user_id");
                return findById(userId);
            }
        }
    }

    // ── Đánh dấu token đã dùng ────────────────────────────────────────────
    public void markTokenUsed(String token) throws SQLException {
        String sql = "UPDATE password_resets SET is_used=1 WHERE reset_token=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }

    // ── [ADMIN] Lấy tất cả user (phân trang) ──────────────────────────────
    public java.util.List<User> getAll(int page, int size) throws SQLException {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT u.*, r.role_name FROM users u "
                + "JOIN roles r ON u.role_id = r.role_id "
                + "ORDER BY u.created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * size);
            ps.setInt(2, size);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── [ADMIN] Đếm tổng user ──────────────────────────────────────────────
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── [ADMIN] Bật/tắt tài khoản ─────────────────────────────────────────
    public boolean toggleActive(int userId) throws SQLException {
        String sql = "UPDATE users SET is_active = CASE WHEN is_active=1 THEN 0 ELSE 1 END WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Xóa user ──────────────────────────────────────────────────
    public boolean deleteUser(int userId) throws SQLException {
        // Xóa theo thứ tự FK: order_items -> orders -> cart_items -> cart -> reviews -> password_resets -> users
        String[] sqls = {
            "DELETE FROM order_items WHERE order_id IN (SELECT order_id FROM orders WHERE user_id=?)",
            "DELETE FROM orders WHERE user_id=?",
            "DELETE FROM cart_items WHERE cart_id IN (SELECT cart_id FROM cart WHERE user_id=?)",
            "DELETE FROM cart WHERE user_id=?",
            "DELETE FROM reviews WHERE user_id=?",
            "DELETE FROM password_resets WHERE user_id=?",
            "DELETE FROM users WHERE user_id=?"
        };
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (String sql : sqls) {
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, userId);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ── [ADMIN] Đổi role user ──────────────────────────────────────────────
    public boolean updateRole(int userId, int roleId) throws SQLException {
        String sql = "UPDATE users SET role_id=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Ánh xạ ResultSet → User object ────────────────────────────────────
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setFullName(rs.getString("full_name"));
        u.setRoleId(rs.getInt("role_id"));
        u.setActive(rs.getBoolean("is_active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            u.setCreatedAt(ts.toLocalDateTime());
        }
        return u;
    }
}
