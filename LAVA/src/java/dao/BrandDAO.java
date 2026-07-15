/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Brand;
import utils.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BrandDAO {

    public List<Brand> getAll() throws SQLException {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM brands ORDER BY brand_id";
        try (Connection conn = DBConnection.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Brand b = new Brand();
                b.setBrandId(rs.getInt("brand_id"));
                b.setBrandName(rs.getString("brand_name"));
                list.add(b);
            }
        }
        return list;
    }

    public Brand findById(int id) throws SQLException {
        String sql = "SELECT * FROM brands WHERE brand_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Brand b = new Brand();
                    b.setBrandId(rs.getInt("brand_id"));
                    b.setBrandName(rs.getString("brand_name"));
                    return b;
                }
            }
        }
        return null;
    }
}
