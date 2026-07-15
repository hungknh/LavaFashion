<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.User, model.Product, java.util.List" %>
<%
    String path = request.getContextPath();
    User   me   = (User) session.getAttribute("loggedUser");
    if (me == null || !me.isAdmin()) { response.sendRedirect(path + "/home"); return; }

    List<Product> products   = (List<Product>) request.getAttribute("products");
    int currentPage          = (Integer) request.getAttribute("currentPage");
    int totalPages           = (Integer) request.getAttribute("totalPages");
    String keyword           = (String)  request.getAttribute("keyword");
    if (products == null) products = new java.util.ArrayList<>();

    String ok  = (String) session.getAttribute("adminSuccess");
    String err = (String) session.getAttribute("adminError");
    session.removeAttribute("adminSuccess"); session.removeAttribute("adminError");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><title>Products – LAVA Admin</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/admin.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
    </head>
    <body>
        <%@ include file="sidebar.jspf" %>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="page-title">Products</div>
                <div class="topbar-right">
                    <a href="<%= path %>/admin/product-form" class="btn btn-primary btn-sm">
                        <i class="fa-solid fa-plus"></i> Add Product
                    </a>
                </div>
            </div>
            <div class="admin-content">
                <% if (ok  != null) { %><div class="alert alert-success" id="adminToast"><i class="fa-solid fa-circle-check"></i> <%= ok %></div><% } %>
                <% if (err != null) { %><div class="alert alert-error"  id="adminToast"><i class="fa-solid fa-circle-exclamation"></i> <%= err %></div><% } %>

                <div class="admin-panel">
                    <div class="panel-header">
                        <span class="panel-title">All Products (<%= products.size() %>)</span>
                        <form method="GET" action="<%= path %>/admin/products" class="search-bar">
                            <input type="text" name="keyword" placeholder="Search by name..."
                                   value="<%= keyword != null ? keyword : "" %>">
                            <button type="submit" class="btn btn-outline btn-sm"><i class="fa-solid fa-magnifying-glass"></i></button>
                                <% if (keyword != null && !keyword.isEmpty()) { %>
                            <a href="<%= path %>/admin/products" class="btn btn-outline btn-sm">Clear</a>
                            <% } %>
                        </form>
                    </div>
                    <div class="panel-body">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>ID</th><th>Image</th><th>Name</th><th>Category</th>
                                    <th>Price</th><th>Stock</th><th>Type</th><th>Status</th><th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (products.isEmpty()) { %>
                                <tr><td colspan="9" style="text-align:center;color:#aaa;padding:40px;">No products found.</td></tr>
                                <% } else { for (Product p : products) { %>
                                <tr>
                                    <td><strong>#<%= p.getProductId() %></strong></td>
                                    <td><img class="product-thumb" src="<%= path %>/<%= p.getDisplayImage() %>" alt="<%= p.getProductName() %>"></td>
                                    <td>
                                        <strong><%= p.getProductName() %></strong>
                                        <% if (p.getColor() != null && !p.getColor().isEmpty()) { %>
                                        <br><small style="color:#aaa;"><%= p.getColor() %></small>
                                        <% } %>
                                    </td>
                                    <td><%= p.getCategoryName() != null ? p.getCategoryName() : "—" %></td>
                                    <td><%= p.getFormattedPrice() %></td>
                                    <td><%= p.getStock() %></td>
                                    <td><%= p.getProductType() != null ? p.getProductType() : "—" %></td>
                                    <td>
                                        <span class="badge <%= p.isActive() ? "badge-active" : "badge-inactive" %>">
                                            <%= p.isActive() ? "Active" : "Hidden" %>
                                        </span>
                                    </td>
                                    <td style="white-space:nowrap;">
                                        <a href="<%= path %>/admin/product-form?id=<%= p.getProductId() %>"
                                           class="btn btn-outline btn-sm"><i class="fa-solid fa-pen"></i></a>
                                        <form method="POST" action="<%= path %>/admin/product-delete" style="display:inline;">
                                            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                            <% if (p.isActive()) { %>
                                            <input type="hidden" name="action" value="delete">
                                            <button type="button" class="btn btn-danger btn-sm"
                                                    onclick="confirmDelete(this.form, 'Hide product &quot;<%= p.getProductName() %>&quot;?')">
                                                <i class="fa-solid fa-eye-slash"></i>
                                            </button>
                                            <% } else { %>
                                            <input type="hidden" name="action" value="restore">
                                            <button type="button" class="btn btn-success btn-sm"
                                                    onclick="confirmDelete(this.form, 'Restore product &quot;<%= p.getProductName() %>&quot;?')">
                                                <i class="fa-solid fa-eye"></i>
                                            </button>
                                            <% } %>
                                        </form>
                                    </td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>

                        <!-- PAGINATION -->
                        <% if (totalPages > 1) { %>
                        <div class="pagination">
                            <% if (currentPage > 1) { %>
                            <a href="?page=<%= currentPage-1 %><%= keyword!=null?"&keyword="+keyword:"" %>"><i class="fa-solid fa-chevron-left"></i></a>
                            <% } else { %><span class="disabled"><i class="fa-solid fa-chevron-left"></i></span><% } %>

                            <% for (int i = 1; i <= totalPages; i++) { %>
                            <a href="?page=<%= i %><%= keyword!=null?"&keyword="+keyword:"" %>"
                               class="<%= i == currentPage ? "current" : "" %>"><%= i %></a>
                            <% } %>

                            <% if (currentPage < totalPages) { %>
                            <a href="?page=<%= currentPage+1 %><%= keyword!=null?"&keyword="+keyword:"" %>"><i class="fa-solid fa-chevron-right"></i></a>
                            <% } else { %><span class="disabled"><i class="fa-solid fa-chevron-right"></i></span><% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <script src="<%= path %>/assets/js/admin.js"></script>
 
    </body>
</html>
