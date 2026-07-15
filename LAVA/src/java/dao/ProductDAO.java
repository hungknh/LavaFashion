/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Product;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // ── Get newest products (for home page) ───────────────────────────────
    public List<Product> getNewest(int limit) throws SQLException {
        String sql = "SELECT TOP (" + limit + ") p.*, c.category_name, b.brand_name, "
                + "(SELECT TOP 1 image_url FROM product_images "
                + " WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.is_active = 1 "
                + "ORDER BY p.created_at DESC";
        return queryList(sql, new ArrayList<>());
    }
    // ── Get products by type (new / featured / best_seller / collection) ──

    public List<Product> getByType(String productType, int limit) throws SQLException {
        String sql = "SELECT TOP (" + limit + ") p.*, c.category_name, b.brand_name, "
                + "(SELECT TOP 1 image_url FROM product_images "
                + " WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.is_active = 1 AND p.product_type = ? "
                + "ORDER BY p.created_at DESC";
        List<Object> params = new ArrayList<>();
        params.add(productType);
        return queryList(sql, params);
    }

// ── Get similar products (same category, exclude current) ────────────
    public List<Product> getSimilar(int categoryId, int excludeId, int limit) throws SQLException {
        String sql = "SELECT TOP (" + limit + ") p.*, c.category_name, b.brand_name, "
                + "(SELECT TOP 1 image_url FROM product_images "
                + " WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.is_active = 1 AND p.category_id = ? AND p.product_id <> ? "
                + "ORDER BY p.rating DESC";
        List<Object> params = new ArrayList<>();
        params.add(categoryId);
        params.add(excludeId);
        return queryList(sql, params);
    }

    // ── Get filtered products (search, filter, sort, paginate) ─────────────
    public List<Product> getFiltered(String keyword, Integer categoryId, Integer brandId,
            Double minPrice, Double maxPrice, String productType, String color,
            String sortBy, int page, int pageSize) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT p.*, c.category_name, b.brand_name, "
                + "(SELECT TOP 1 image_url FROM product_images "
                + " WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.is_active = 1 "
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR b.brand_name LIKE ? OR c.category_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
        }
        if (brandId != null && brandId > 0) {
            sql.append("AND p.brand_id = ? ");
            params.add(brandId);
        }
        if (minPrice != null) {
            sql.append("AND p.price >= ? ");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append("AND p.price <= ? ");
            params.add(maxPrice);
        }
        if (productType != null && !productType.trim().isEmpty()) {
            sql.append("AND p.product_type = ? ");
            params.add(productType.trim());
        }
        if (color != null && !color.trim().isEmpty()) {
            sql.append("AND LOWER(p.color) LIKE LOWER(?) ");
            params.add("%" + color.trim() + "%");
        }

        switch (sortBy == null ? "" : sortBy) {
            case "price_asc":
                sql.append("ORDER BY p.price ASC ");
                break;
            case "price_desc":
                sql.append("ORDER BY p.price DESC ");
                break;
            case "name_asc":
                sql.append("ORDER BY p.product_name ASC ");
                break;
            default:
                sql.append("ORDER BY p.created_at DESC ");
                break;
        }

        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        return queryList(sql.toString(), params);
    }

    // ── Count filtered results (for pagination total pages) ───────────────
    public int countFiltered(String keyword, Integer categoryId, Integer brandId,
            Double minPrice, Double maxPrice, String productType, String color) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.is_active = 1 "
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.product_name LIKE ? OR b.brand_name LIKE ? OR c.category_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
        }
        if (brandId != null && brandId > 0) {
            sql.append("AND p.brand_id = ? ");
            params.add(brandId);
        }
        if (minPrice != null) {
            sql.append("AND p.price >= ? ");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append("AND p.price <= ? ");
            params.add(maxPrice);
        }
        if (productType != null && !productType.trim().isEmpty()) {
            sql.append("AND p.product_type = ? ");
            params.add(productType.trim());
        }
        if (color != null && !color.trim().isEmpty()) {
            sql.append("AND LOWER(p.color) LIKE LOWER(?) ");
            params.add("%" + color.trim() + "%");
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ── Get single product by ID (with all image URLs) ────────────────────
    public Product findById(int productId) throws SQLException {
        String sql
                = "SELECT p.*, c.category_name, b.brand_name, "
                + "(SELECT TOP 1 image_url FROM product_images "
                + " WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ? AND p.is_active = 1";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapRow(rs);
                    // Load all image URLs as List<String>
                    p.setImages(getImageUrls(productId));
                    p.setSizeStocks(getSizeStocks(productId));
                    return p;
                }
            }
        }
        return null;
    }

    // ── Get all image URLs of a product as List<String> ───────────────────
    public List<String> getImageUrls(int productId) throws SQLException {
        List<String> urls = new ArrayList<>();
        String sql = "SELECT image_url FROM product_images "
                + "WHERE product_id = ? ORDER BY is_primary DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    urls.add(rs.getString("image_url"));
                }
            }
        }
        return urls;
    }

    // ── Get size → stock map for a product ───────────────────────────────
    public java.util.LinkedHashMap<String, Integer> getSizeStocks(int productId) throws SQLException {
        java.util.LinkedHashMap<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT size, stock FROM product_sizes WHERE product_id = ? "
                + "ORDER BY CASE size WHEN 'S' THEN 1 WHEN 'M' THEN 2 WHEN 'L' THEN 3 "
                + "WHEN 'XL' THEN 4 WHEN 'XXL' THEN 5 ELSE 6 END";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("size"), rs.getInt("stock"));
                }
            }
        }
        return map;
    }

    // ── [ADMIN] Get all products with pagination ───────────────────────────
    public List<Product> getAllForAdmin(int page, int pageSize) throws SQLException {
        String sql
                = "SELECT p.*, c.category_name, b.brand_name, "
                + "(SELECT TOP 1 image_url FROM product_images "
                + " WHERE product_id = p.product_id AND is_primary = 1) AS primary_image "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "ORDER BY p.created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        List<Object> params = new ArrayList<>();
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        return queryList(sql, params);
    }

    // ── [ADMIN] Count all products ─────────────────────────────────────────
    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── [ADMIN] Insert product, return new product_id ─────────────────────
    public int insert(Product p) throws SQLException {
        String sql = "INSERT INTO products (product_name, description, price, stock, "
                + "category_id, brand_id, color, product_type, is_active) "
                + "VALUES (?,?,?,?,?,?,?,?,1)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getProductName());
            ps.setString(2, p.getDescription());
            ps.setDouble(3, p.getPrice());
            ps.setInt(4, p.getStock());
            ps.setInt(5, p.getCategoryId());
            ps.setInt(6, p.getBrandId());
            ps.setString(7, p.getColor());
            ps.setString(8, p.getProductType());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : -1;
            }
        }
    }

    // ── [ADMIN] Update product ─────────────────────────────────────────────
    public boolean update(Product p) throws SQLException {
        String sql = "UPDATE products SET product_name=?, description=?, price=?, "
                + "stock=?, category_id=?, brand_id=?, color=?, product_type=?, is_active=? "
                + "WHERE product_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getProductName());
            ps.setString(2, p.getDescription());
            ps.setDouble(3, p.getPrice());
            ps.setInt(4, p.getStock());
            ps.setInt(5, p.getCategoryId());
            ps.setInt(6, p.getBrandId());
            ps.setString(7, p.getColor());
            ps.setString(8, p.getProductType());
            ps.setBoolean(9, p.isActive());
            ps.setInt(10, p.getProductId());
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Soft-delete: ẩn SP khỏi storefront ───────────────────────
    public boolean softDelete(int productId) throws SQLException {
        String sql = "UPDATE products SET is_active = 0 WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Restore soft-deleted product ─────────────────────────────
    public boolean restore(int productId) throws SQLException {
        String sql = "UPDATE products SET is_active = 1 WHERE product_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Delete product ─────────────────────────────────────────────
    public boolean delete(int productId) throws SQLException {
        String sql = "DELETE FROM products WHERE product_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Add image URL for a product ───────────────────────────────
    public boolean addImage(int productId, String imageUrl, boolean isPrimary) throws SQLException {
        if (isPrimary) {
            String reset = "UPDATE product_images SET is_primary=0 WHERE product_id=?";
            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(reset)) {
                ps.setInt(1, productId);
                ps.executeUpdate();
            }
        }
        String sql = "INSERT INTO product_images (product_id, image_url, is_primary) VALUES (?,?,?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            ps.setBoolean(3, isPrimary);
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Xóa 1 ảnh theo URL ──────────────────────────────────────
    public boolean deleteImage(int productId, String imageUrl) throws SQLException {
        String sql = "DELETE FROM product_images WHERE product_id=? AND image_url=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Xóa tất cả ảnh của SP ────────────────────────────────────
    public boolean deleteAllImages(int productId) throws SQLException {
        String sql = "DELETE FROM product_images WHERE product_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── [ADMIN] Upsert size stocks vào product_sizes ────────────────────
    public void updateSizeStocks(int productId, java.util.LinkedHashMap<String, Integer> sizeMap)
            throws SQLException {
        // Xóa size cũ rồi insert lại
        String del = "DELETE FROM product_sizes WHERE product_id = ?";
        String ins = "INSERT INTO product_sizes (product_id, size, stock) VALUES (?,?,?)";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(del)) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(ins)) {
                    for (java.util.Map.Entry<String, Integer> e : sizeMap.entrySet()) {
                        ps.setInt(1, productId);
                        ps.setString(2, e.getKey());
                        ps.setInt(3, e.getValue());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ── Get distinct non-null colors for filter dropdown ──────────────────
    public List<String> getDistinctColors() throws SQLException {
        List<String> colors = new ArrayList<>();
        String sql = "SELECT DISTINCT color FROM products "
                + "WHERE is_active = 1 AND color IS NOT NULL AND color != '' "
                + "ORDER BY color";
        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                colors.add(rs.getString("color"));
            }
        }
        return colors;
    }

    // ── Helpers ────────────────────────────────────────────────────────────
    private List<Product> queryList(String sql, List<Object> params) throws SQLException {
        List<Product> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    private void setParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object val = params.get(i);
            if (val instanceof String) {
                ps.setString(i + 1, (String) val);
            } else if (val instanceof Integer) {
                ps.setInt(i + 1, (Integer) val);
            } else if (val instanceof Double) {
                ps.setDouble(i + 1, (Double) val);
            } else {
                ps.setObject(i + 1, val);
            }
        }
    }

    // Map ResultSet → Product (matches actual Product.java fields)
    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setProductName(rs.getString("product_name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getDouble("price"));
        p.setColor(rs.getString("color"));
        p.setRating(rs.getDouble("rating"));
        p.setProductType(rs.getString("product_type"));
        p.setStock(rs.getInt("stock"));                // column name in DB is "stock"
        p.setCategoryId(rs.getInt("category_id"));
        p.setBrandId(rs.getInt("brand_id"));
        p.setActive(rs.getBoolean("is_active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            p.setCreatedAt(ts.toLocalDateTime());
        }
        // Joined fields
        p.setCategoryName(rs.getString("category_name"));
        p.setBrandName(rs.getString("brand_name"));
        p.setPrimaryImage(rs.getString("primary_image"));
        return p;
    }
}
