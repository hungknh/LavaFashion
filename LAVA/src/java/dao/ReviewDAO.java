package dao;

import model.Review;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    public List<Review> getByProductId(int productId) throws SQLException {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, u.full_name FROM reviews r "
                + "JOIN users u ON r.user_id = u.user_id "
                + "WHERE r.product_id = ? ORDER BY r.created_at DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review rv = new Review();
                    rv.setReviewId(rs.getInt("review_id"));
                    rv.setProductId(rs.getInt("product_id"));
                    rv.setUserId(rs.getInt("user_id"));
                    rv.setUsername(rs.getString("username"));
                    rv.setFullName(rs.getString("full_name"));
                    rv.setRating(rs.getInt("rating"));
                    rv.setComment(rs.getString("comment"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        rv.setCreatedAt(ts.toLocalDateTime());
                    }
                    list.add(rv);
                }
            }
        }
        return list;
    }

    public boolean hasReviewed(int userId, int productId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reviews WHERE user_id=? AND product_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public boolean add(Review review) throws SQLException {
        String sql = "INSERT INTO reviews (product_id, user_id, rating, comment) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, review.getProductId());
            ps.setInt(2, review.getUserId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getComment());
            return ps.executeUpdate() > 0;
        }
    }

    public void updateProductRating(int productId) throws SQLException {
        String sql = "UPDATE products SET rating = "
                + "(SELECT AVG(CAST(rating AS FLOAT)) FROM reviews WHERE product_id=?) "
                + "WHERE product_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, productId);
            ps.executeUpdate();
        }
    }
}
