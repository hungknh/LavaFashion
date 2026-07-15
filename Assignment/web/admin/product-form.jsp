<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.User, model.Product, model.Category, model.Brand, java.util.List" %>
<%
    String path = request.getContextPath();
    User   me   = (User) session.getAttribute("loggedUser");
    if (me == null || !me.isAdmin()) { response.sendRedirect(path + "/home"); return; }

    Product        product    = (Product)        request.getAttribute("product");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand>    brands     = (List<Brand>)    request.getAttribute("brands");
    if (categories == null) categories = new java.util.ArrayList<>();
    if (brands     == null) brands     = new java.util.ArrayList<>();

    boolean isEdit = (product != null);
    String formTitle = isEdit ? "Edit Product" : "Add New Product";
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><title><%= formTitle %> – LAVA Admin</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/admin.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
    </head>
    <body>
        <%@ include file="sidebar.jspf" %>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="page-title"><%= formTitle %></div>
                <div class="topbar-right">
                    <a href="<%= path %>/admin/products" class="btn btn-outline btn-sm">
                        <i class="fa-solid fa-arrow-left"></i> Back to Products
                    </a>
                </div>
            </div>
            <div class="admin-content">
                <div class="admin-panel" style="max-width:780px;">
                    <div class="panel-header">
                        <span class="panel-title"><%= formTitle %></span>
                    </div>
                    <div class="panel-body" style="padding:28px;">
                        <form method="POST" action="<%= path %>/admin/product-form" class="admin-form">
                            <% if (isEdit) { %>
                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                            <% } %>

                            <div class="form-grid">

                                <!-- Product Name -->
                                <div class="form-group full">
                                    <label>Product Name *</label>
                                    <input type="text" name="productName" required
                                           placeholder="e.g. Classic White Oxford Shirt"
                                           value="<%= isEdit ? product.getProductName() : "" %>">
                                </div>

                                <!-- Price + Stock -->
                                <div class="form-group">
                                    <label>Price (USD) *</label>
                                    <input type="number" name="price" step="0.01" min="0" required
                                           placeholder="e.g. 49.99"
                                           value="<%= isEdit ? product.getPrice() : "" %>">
                                </div>
                                <div class="form-group">
                                    <label>Stock (total, auto-calculated)</label>
                                    <input type="number" name="stock" id="totalStock" min="0"
                                           placeholder="Auto-sum from sizes below"
                                           value="<%= isEdit ? product.getStock() : "" %>" readonly
                                           style="background:#f7f7f7;color:#888;">
                                </div>
                                <!-- Size quantities -->
                                <div class="form-group full" style="margin-top:4px;">
                                    <label>Stock per Size *</label>
                                    <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-top:6px;">
                                        <% String[] sizes = {"S","M","L","XL","XXL"};
                                           java.util.Map<String,Integer> sizeMap = new java.util.LinkedHashMap<>();
                                           if (isEdit && product.getSizeStocks() != null) sizeMap = product.getSizeStocks();
                                           for (String sz : sizes) {
                                               int qty = sizeMap.containsKey(sz) ? sizeMap.get(sz) : 0; %>
                                        <div>
                                            <label style="font-size:11px;font-weight:700;text-align:center;display:block;margin-bottom:4px;"><%= sz %></label>
                                            <input type="number" name="size_<%= sz %>"
                                                   min="0" value="<%= qty %>"
                                                   placeholder="0"
                                                   oninput="recalcTotal()"
                                                   style="text-align:center;width:100%;">
                                        </div>
                                        <% } %>
                                    </div>
                                </div>

                                <!-- Category + Brand -->
                                <div class="form-group">
                                    <label>Category *</label>
                                    <select name="categoryId" required>
                                        <option value="">-- Select Category --</option>
                                        <% for (Category c : categories) { %>
                                        <option value="<%= c.getCategoryId() %>"
                                                <%= isEdit && product.getCategoryId() == c.getCategoryId() ? "selected" : "" %>>
                                            <%= c.getCategoryName() %>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Brand *</label>
                                    <select name="brandId" required>
                                        <option value="">-- Select Brand --</option>
                                        <% for (Brand b : brands) { %>
                                        <option value="<%= b.getBrandId() %>"
                                                <%= isEdit && product.getBrandId() == b.getBrandId() ? "selected" : "" %>>
                                            <%= b.getBrandName() %>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>

                                <!-- Color + Product Type -->
                                <div class="form-group">
                                    <label>Color</label>
                                    <input type="text" name="color"
                                           placeholder="e.g. Black, White, Navy"
                                           value="<%= isEdit && product.getColor() != null ? product.getColor() : "" %>">
                                </div>
                                <div class="form-group">
                                    <label>Product Type</label>
                                    <select name="productType">
                                        <option value="">-- None --</option>
                                        <% String[] types = {"featured","new","best_seller"}; %>
                                        <% for (String t : types) { %>
                                        <option value="<%= t %>"
                                                <%= isEdit && t.equals(product.getProductType()) ? "selected" : "" %>>
                                            <%= t.replace("_"," ").toUpperCase() %>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>

                                <!-- Description -->
                                <div class="form-group full">
                                    <label>Description</label>
                                    <textarea name="description"
                                              placeholder="Product description..."><%= isEdit && product.getDescription() != null ? product.getDescription() : "" %></textarea>
                                </div>

                                <!-- Image URL -->
                                <div class="form-group full">
                                    <label>Primary Image URL</label>
                                    <input type="text" name="imageUrl" id="imageUrlInput"
                                           placeholder="e.g. assets/images/shirt1.jpg"
                                           value="<%= isEdit && product.getDisplayImage() != null ? product.getDisplayImage() : "" %>"
                                           oninput="previewImage(this,'imgPreview')">
                                    <% if (isEdit && product.getDisplayImage() != null) { %>
                                    <img id="imgPreview" class="img-preview"
                                         src="<%= path %>/<%= product.getDisplayImage() %>" alt="Preview">
                                    <% } else { %>
                                    <img id="imgPreview" class="img-preview" style="display:none;" alt="Preview">
                                    <% } %>
                                    <small style="color:#aaa;margin-top:4px;font-size:11px;">
                                        Enter a relative path from project root. Current images shown above.
                                    </small>
                                </div>

                                <!-- Existing images (edit mode) -->
                                <% if (isEdit && product.getImages() != null && !product.getImages().isEmpty()) { %>
                                <div class="form-group full">
                                    <label>Current Images <span style="font-weight:400;color:#aaa;font-size:11px;">(click X to delete)</span></label>
                                    <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:8px;">
                                        <% for (String img : product.getImages()) { %>
                                        <div style="position:relative;display:inline-block;">
                                            <img src="<%= path %>/<%= img %>"
                                                 style="width:64px;height:82px;object-fit:cover;border:1px solid #eee;display:block;"
                                                 title="<%= img %>">
                                            <form method="POST"
                                                  action="<%= path %>/admin/product-image-delete"
                                                  style="position:absolute;top:-6px;right:-6px;margin:0;">
                                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                                <input type="hidden" name="imageUrl"  value="<%= img %>">
                                                <button type="button"
                                                        onclick="confirmDelete(this.form, 'Delete this image?')"
                                                        style="width:20px;height:20px;border-radius:50%;background:#e74c3c;color:#fff;border:none;cursor:pointer;font-size:11px;font-weight:700;line-height:1;padding:0;display:flex;align-items:center;justify-content:center;"
                                                        title="Delete image">✕</button>
                                            </form>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>
                                <% } %>

                            </div><!-- /form-grid -->

                            <div style="margin-top:24px;display:flex;gap:12px;">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa-solid fa-floppy-disk"></i>
                                    <%= isEdit ? "Save Changes" : "Add Product" %>
                                </button>
                                <a href="<%= path %>/admin/products" class="btn btn-outline">Cancel</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <script src="<%= path %>/assets/js/admin.js"></script>
        <script>
                                                            function recalcTotal() {
                                                                var sizes = ["S", "M", "L", "XL", "XXL"];
                                                                var total = 0;
                                                                sizes.forEach(function (s) {
                                                                    var v = parseInt(document.querySelector('[name="size_' + s + '"]').value) || 0;
                                                                    total += v;
                                                                });
                                                                document.getElementById("totalStock").value = total;
                                                            }
                                                            // Run on load for edit mode
                                                            recalcTotal();
        </script>
       
    </body>
</html>
