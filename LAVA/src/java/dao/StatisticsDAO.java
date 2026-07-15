package dao;

import utils.DBConnection;
import java.sql.*;
import java.util.*;

public class StatisticsDAO {

    // ── Doanh thu theo từng ngày trong 1 tháng ────────────────────────────
    // Chỉ tính đơn Delivered (đã giao thành công)
    public Map<Integer, Double> getRevenueByDay(int year, int month) throws SQLException {
        Map<Integer, Double> map = new LinkedHashMap<>();
        // Khởi tạo 31 ngày = 0
        for (int d = 1; d <= 31; d++) {
            map.put(d, 0.0);
        }

        String sql = "SELECT DAY(created_at) AS day, SUM(total_price) AS revenue "
                + "FROM orders "
                + "WHERE status = 'Delivered' AND payment_status = 'Paid' "
                + "  AND YEAR(created_at) = ? "
                + "  AND MONTH(created_at) = ? "
                + "GROUP BY DAY(created_at) "
                + "ORDER BY DAY(created_at)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("day"), rs.getDouble("revenue"));
                }
            }
        }
        return map;
    }

    // ── Doanh thu 12 tháng trong 1 năm (cho biểu đồ) ─────────────────────
    public Map<Integer, Double> getRevenueByMonth(int year) throws SQLException {
        Map<Integer, Double> map = new LinkedHashMap<>();
        for (int m = 1; m <= 12; m++) {
            map.put(m, 0.0);
        }

        String sql = "SELECT MONTH(created_at) AS month, SUM(total_price) AS revenue "
                + "FROM orders "
                + "WHERE status = 'Delivered' AND payment_status = 'Paid' "
                + "  AND YEAR(created_at) = ? "
                + "GROUP BY MONTH(created_at) "
                + "ORDER BY MONTH(created_at)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("month"), rs.getDouble("revenue"));
                }
            }
        }
        return map;
    }

    // ── Tổng doanh thu năm ────────────────────────────────────────────────
    public double getTotalRevenueByYear(int year) throws SQLException {
        String sql = "SELECT ISNULL(SUM(total_price), 0) FROM orders "
                + "WHERE status = 'Delivered' AND payment_status = 'Paid' AND YEAR(created_at) = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0;
            }
        }
    }

    // ── Tổng doanh thu tháng ──────────────────────────────────────────────
    public double getTotalRevenueByMonth(int year, int month) throws SQLException {
        String sql = "SELECT ISNULL(SUM(total_price), 0) FROM orders "
                + "WHERE status = 'Delivered' AND payment_status = 'Paid' "
                + "  AND YEAR(created_at) = ? AND MONTH(created_at) = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0;
            }
        }
    }

    // ── Top sản phẩm bán chạy nhất ───────────────────────────────────────
    // List<Object[]>: [productId, productName, categoryName, totalQty, totalRevenue]
    public List<Object[]> getTopSellingProducts(int limit) throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.product_id, p.product_name, "
                + "  c.category_name, "
                + "  SUM(oi.quantity)           AS total_qty, "
                + "  SUM(oi.quantity * oi.price) AS total_revenue, "
                + "  (SELECT TOP 1 image_url FROM product_images "
                + "   WHERE product_id = p.product_id AND is_primary = 1) AS img "
                + "FROM order_items oi "
                + "JOIN products p   ON oi.product_id = p.product_id "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN orders o     ON oi.order_id   = o.order_id "
                + "WHERE o.status = 'Delivered' AND o.payment_status = 'Paid' "
                + "GROUP BY p.product_id, p.product_name, c.category_name "
                + "ORDER BY total_qty DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{
                        rs.getInt("product_id"),
                        rs.getString("product_name"),
                        rs.getString("category_name"),
                        rs.getInt("total_qty"),
                        rs.getDouble("total_revenue"),
                        rs.getString("img")
                    });
                }
            }
        }
        return list;
    }

    // ── Top sản phẩm đánh giá cao nhất ───────────────────────────────────
    // List<Object[]>: [productId, productName, categoryName, avgRating, reviewCount, img]
    public List<Object[]> getTopRatedProducts(int limit) throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.product_id, p.product_name, "
                + "  c.category_name, "
                + "  ROUND(AVG(CAST(r.rating AS FLOAT)), 1) AS avg_rating, "
                + "  COUNT(r.review_id)                     AS review_count, "
                + "  (SELECT TOP 1 image_url FROM product_images "
                + "   WHERE product_id = p.product_id AND is_primary = 1) AS img "
                + "FROM reviews r "
                + "JOIN products   p ON r.product_id = p.product_id "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "GROUP BY p.product_id, p.product_name, c.category_name "
                + "HAVING COUNT(r.review_id) >= 1 "
                + "ORDER BY avg_rating DESC, review_count DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{
                        rs.getInt("product_id"),
                        rs.getString("product_name"),
                        rs.getString("category_name"),
                        rs.getDouble("avg_rating"),
                        rs.getInt("review_count"),
                        rs.getString("img")
                    });
                }
            }
        }
        return list;
    }

    // ── Số lượng SP theo từng danh mục ────────────────────────────────────
    // List<Object[]>: [categoryName, activeCount, totalCount]
    public List<Object[]> getProductCountByCategory() throws SQLException {
        List<Object[]> list = new ArrayList<>();
        String sql = "SELECT c.category_name, "
                + "  SUM(CASE WHEN p.is_active = 1 THEN 1 ELSE 0 END) AS active_count, "
                + "  COUNT(p.product_id)                               AS total_count "
                + "FROM categories c "
                + "LEFT JOIN products p ON c.category_id = p.category_id "
                + "GROUP BY c.category_id, c.category_name "
                + "ORDER BY total_count DESC";

        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new Object[]{
                    rs.getString("category_name"),
                    rs.getInt("active_count"),
                    rs.getInt("total_count")
                });
            }
        }
        return list;
    }

    // ── User mới đăng ký từng tháng ──────────────────────────────────────
    public Map<Integer, Integer> getNewCustomersByMonth(int year) throws SQLException {
        Map<Integer, Integer> map = new LinkedHashMap<>();
        for (int m = 1; m <= 12; m++) {
            map.put(m, 0);
        }

        String sql = "SELECT MONTH(created_at) AS month, COUNT(*) AS cnt "
                + "FROM users "
                + "WHERE role_id = 2 AND YEAR(created_at) = ? "
                + "GROUP BY MONTH(created_at) "
                + "ORDER BY MONTH(created_at)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("month"), rs.getInt("cnt"));
                }
            }
        }
        return map;
    }

    // ── Tổng số đơn hàng theo trạng thái ─────────────────────────────────
    public Map<String, Integer> getOrderCountByStatus() throws SQLException {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS cnt FROM orders GROUP BY status";
        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        }
        return map;
    }
}
