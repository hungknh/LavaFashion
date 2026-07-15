<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.User, java.util.List" %>
<%
    String path = request.getContextPath();
    User   me   = (User) session.getAttribute("loggedUser");
    if (me == null || !me.isAdmin()) { response.sendRedirect(path + "/home"); return; }

    List<User> users   = (List<User>) request.getAttribute("users");
    int currentPage    = (Integer)   request.getAttribute("currentPage");
    int totalPages     = (Integer)   request.getAttribute("totalPages");
    if (users == null) users = new java.util.ArrayList<>();

    String ok  = (String) session.getAttribute("adminSuccess");
    String err = (String) session.getAttribute("adminError");
    session.removeAttribute("adminSuccess"); session.removeAttribute("adminError");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><title>Users – LAVA Admin</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/admin.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
    </head>
    <body>
        <%@ include file="sidebar.jspf" %>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="page-title">User Management</div>
                <div class="topbar-right">
                    <span style="font-size:12px;color:#888;">Total: <%= users.size() %> users on this page</span>
                </div>
            </div>
            <div class="admin-content">
                <% if (ok  != null) { %><div class="alert alert-success" id="adminToast"><i class="fa-solid fa-circle-check"></i> <%= ok %></div><% } %>
                <% if (err != null) { %><div class="alert alert-error"   id="adminToast"><i class="fa-solid fa-circle-exclamation"></i> <%= err %></div><% } %>

                <div class="admin-panel">
                    <div class="panel-header">
                        <span class="panel-title">All Users</span>
                    </div>
                    <div class="panel-body">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>ID</th><th>Username</th><th>Full Name</th>
                                    <th>Email</th><th>Phone</th><th>Role</th>
                                    <th>Status</th><th>Joined</th><th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (users.isEmpty()) { %>
                                <tr><td colspan="9" style="text-align:center;color:#aaa;padding:40px;">No users found.</td></tr>
                                <% } else { for (User u : users) { %>
                                <tr>
                                    <td><strong>#<%= u.getUserId() %></strong></td>
                                    <td>
                                        <strong><%= u.getUsername() %></strong>
                                        <% if (u.getUserId() == me.getUserId()) { %>
                                        <span style="font-size:10px;background:#eee;padding:1px 6px;margin-left:4px;">You</span>
                                        <% } %>
                                    </td>
                                    <td><%= u.getFullName() != null ? u.getFullName() : "—" %></td>
                                    <td style="font-size:12px;"><%= u.getEmail() != null ? u.getEmail() : "—" %></td>
                                    <td><%= u.getPhone() != null && !u.getPhone().isEmpty() ? u.getPhone() : "—" %></td>
                                    <td>
                                        <span class="badge <%= u.getRoleId() == 1 ? "badge-admin" : "badge-user" %>">
                                            <%= u.getRoleId() == 1 ? "Admin" : "User" %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge <%= u.isActive() ? "badge-active" : "badge-inactive" %>">
                                            <%= u.isActive() ? "Active" : "Disabled" %>
                                        </span>
                                    </td>
                                    <td style="font-size:12px;color:#888;">
                                        <%= u.getCreatedAt() != null ? u.getCreatedAt().toLocalDate().toString() : "—" %>
                                    </td>
                                    <td style="white-space:nowrap;">
                                        <% if (u.getUserId() != me.getUserId()) { %>
                                        <!-- Toggle Active -->
                                        <form method="POST" action="<%= path %>/admin/user-action" style="display:inline;">
                                            <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                            <input type="hidden" name="action" value="toggle">
                                            <button type="button"
                                                    class="btn btn-sm <%= u.isActive() ? "btn-warning" : "btn-success" %>"
                                                    onclick="confirmDelete(this.form, '<%= u.isActive() ? "Disable" : "Enable" %> user &quot;<%= u.getUsername() %>&quot;?')"
                                                    title="<%= u.isActive() ? "Disable account" : "Enable account" %>">
                                                <i class="fa-solid <%= u.isActive() ? "fa-ban" : "fa-circle-check" %>"></i>
                                            </button>
                                        </form>
                                        <!-- Toggle Role -->
                                        <form method="POST" action="<%= path %>/admin/user-action" style="display:inline;">
                                            <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                            <input type="hidden" name="action" value="setRole">
                                            <input type="hidden" name="roleId" value="<%= u.getRoleId() == 1 ? 2 : 1 %>">
                                            <button type="button"
                                                    class="btn btn-outline btn-sm"
                                                    onclick="confirmDelete(this.form, '<%= u.getRoleId()==1 ? "Demote to User" : "Promote to Admin" %>: &quot;<%= u.getUsername() %>&quot;?')"
                                                    title="<%= u.getRoleId()==1 ? "Demote to User" : "Promote to Admin" %>">
                                                <i class="fa-solid <%= u.getRoleId()==1 ? "fa-user-minus" : "fa-user-plus" %>"></i>
                                            </button>
                                        </form>
                                        <!-- Delete -->
                                        <form method="POST" action="<%= path %>/admin/user-action" style="display:inline;">
                                            <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                            <input type="hidden" name="action" value="delete">
                                            <button type="button" class="btn btn-danger btn-sm"
                                                    onclick="confirmDelete(this.form, 'Permanently delete user &quot;<%= u.getUsername() %>&quot;? This cannot be undone.')"
                                                    title="Delete user">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                        <% } else { %>
                                        <span style="font-size:11px;color:#aaa;">—</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>

                        <!-- PAGINATION -->
                        <% if (totalPages > 1) { %>
                        <div class="pagination">
                            <% if (currentPage > 1) { %>
                            <a href="?page=<%= currentPage-1 %>"><i class="fa-solid fa-chevron-left"></i></a>
                            <% } else { %><span class="disabled"><i class="fa-solid fa-chevron-left"></i></span><% } %>
                                <% for (int i = 1; i <= totalPages; i++) { %>
                            <a href="?page=<%= i %>" class="<%= i==currentPage ? "current" : "" %>"><%= i %></a>
                            <% } %>
                            <% if (currentPage < totalPages) { %>
                            <a href="?page=<%= currentPage+1 %>"><i class="fa-solid fa-chevron-right"></i></a>
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
