/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.time.LocalDateTime;
import java.util.List;

public class Product {

    private int productId;
    private String productName;
    private String description;
    private double price;
    private String color;
    private int categoryId;
    private String categoryName;   // join từ categories
    private int brandId;
    private String brandName;      // join từ brands
    private double rating;
    private int stock;
    private String sizes;
    private String productType;    // featured | new | best_seller
    private boolean isActive;
    private LocalDateTime createdAt;

    // Ảnh sản phẩm (load kèm khi cần)
    private java.util.LinkedHashMap<String, Integer> sizeStocks;
    private String primaryImage;          // ảnh chính (is_primary = 1)
    private List<String> images;          // tất cả ảnh

    public Product() {
    }

    // ── Getters & Setters ──────────────────────────────────────────────────
    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getSizes() {
        return sizes;
    }

    public void setSizes(String sizes) {
        this.sizes = sizes;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public String getProductType() {
        return productType;
    }

    public void setProductType(String productType) {
        this.productType = productType;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        this.isActive = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getPrimaryImage() {
        return primaryImage;
    }

    public void setPrimaryImage(String primaryImage) {
        this.primaryImage = primaryImage;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }

    // ── Helper ────────────────────────────────────────────────────────────
    public boolean isInStock() {
        return stock > 0;
    }

    public java.util.LinkedHashMap<String, Integer> getSizeStocks() {
        return sizeStocks;
    }

    public void setSizeStocks(java.util.LinkedHashMap<String, Integer> sizeStocks) {
        this.sizeStocks = sizeStocks;
    }

    // Trả về ảnh đại diện, fallback nếu không có
    public String getDisplayImage() {
        if (primaryImage != null && !primaryImage.isEmpty()) {
            return primaryImage;
        }
        if (images != null && !images.isEmpty()) {
            return images.get(0);
        }
        return "assets/images/no-image.png";
    }

    // Format giá hiển thị
    public String getFormattedPrice() {
        return String.format("$%.2f", price);
    }
}
