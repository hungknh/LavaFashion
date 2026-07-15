<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    String path       = request.getContextPath();
    User   loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(path + "/auth?action=loginForm"); return; }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>Edit Profile – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            .edit-wrap{
                max-width:560px;
                margin:48px auto;
                padding:0 24px
            }
            .edit-title{
                font-size:20px;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1px;
                margin-bottom:28px;
                padding-bottom:14px;
                border-bottom:1px solid #eee
            }
            .form-group{
                display:flex;
                flex-direction:column;
                margin-bottom:20px
            }
            .form-group label{
                font-size:12px;
                font-weight:600;
                text-transform:uppercase;
                letter-spacing:.5px;
                color:#555;
                margin-bottom:6px
            }
            .form-group input{
                padding:11px 14px;
                border:1px solid #ddd;
                font-size:14px;
                outline:none;
                font-family:inherit
            }
            .form-group input:focus{
                border-color:#111
            }
            .form-group input[readonly]{
                background:#f7f7f7;
                color:#999;
                cursor:not-allowed
            }
            .hint{
                font-size:11px;
                color:#aaa;
                margin-top:4px
            }
            .btn-save{
                padding:13px 36px;
                background:#111;
                color:#fff;
                border:none;
                font-size:13px;
                letter-spacing:1px;
                cursor:pointer
            }
            .btn-save:hover{
                background:#333
            }
            .btn-back{
                font-size:13px;
                color:#888;
                text-decoration:none;
                margin-left:16px
            }
            .btn-back:hover{
                color:#111
            }
            .alert-error{
                background:#f8d7da;
                color:#721c24;
                border:1px solid #f5c6cb;
                padding:12px 16px;
                font-size:14px;
                margin-bottom:20px
            }
            .field-valid{
                border-color:#27ae60 !important
            }
            .field-invalid{
                border-color:#e74c3c !important
            }
            .field-msg{
                font-size:11px;
                margin-top:4px
            }
            .msg-ok{
                color:#27ae60
            }
            .msg-err{
                color:#e74c3c
            }
        </style>
    </head>
    <body>

        <header class="header">
            <div class="menu-left">
                <i class="fa-solid fa-bars fa-xl menu-icon" onclick="openMenu()"></i>
                <a href="<%= path %>/home">Home</a>
                <a href="<%= path %>/products">Products</a>
            </div>
            <div class="logo">
                <a href="<%= path %>/home" style="text-decoration:none;color:black;"><i class="fa-brands fa-atlassian fa-xl"></i></a>
            </div>
            <div class="menu-right">
                <span style="font-size:14px;color:#555;">Hi, <strong><%= loggedUser.getDisplayName() %></strong></span>
                <span>|</span>
                <a href="<%= path %>/profile" class="icon">My Profile</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=logout" class="icon">Sign Out</a>
                <a href="<%= path %>/cart" class="cart"><i class="fa-solid fa-basket-shopping fa-xl"></i></a>
            </div>
        </header>
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>
        <div id="sideMenu" class="side-menu">
            <div class="close-btn" onclick="closeMenu()">✕</div>
            <a href="<%= path %>/home">Home</a>
            <a href="<%= path %>/products">Products</a>
            <a href="<%= path %>/profile">My Profile</a>
            <a href="<%= path %>/auth?action=logout">Sign Out</a>
        </div>

        <div class="edit-wrap">
            <div class="edit-title">Edit Profile</div>

            <% if (error != null) { %>
            <div class="alert-error"><i class="fa-solid fa-circle-exclamation"></i> <%= error %></div>
            <% } %>

            <form method="POST" action="<%= path %>/edit-profile" id="editForm">

                <div class="form-group">
                    <label>Username</label>
                    <input type="text" value="<%= loggedUser.getUsername() %>" readonly>
                    <span class="hint">Username cannot be changed.</span>
                </div>

                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" name="fullName" id="fullName"
                           value="<%= loggedUser.getFullName() != null ? loggedUser.getFullName() : "" %>"
                           placeholder="Enter your full name" required
                           oninput="validateName()">
                    <span class="field-msg" id="nameMsg"></span>
                </div>

                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email" id="email"
                           value="<%= loggedUser.getEmail() != null ? loggedUser.getEmail() : "" %>"
                           placeholder="Enter your email" required
                           oninput="validateEmail()">
                    <span class="field-msg" id="emailMsg"></span>
                </div>

                <div class="form-group">
                    <label>Phone</label>
                    <input type="text" name="phone" id="phone"
                           value="<%= loggedUser.getPhone() != null ? loggedUser.getPhone() : "" %>"
                           placeholder="e.g. 0912345678"
                           oninput="validatePhone()">
                    <span class="field-msg" id="phoneMsg"></span>
                    <span class="hint">Format: 0xxxxxxxxx (exactly 10 digits, starts with 0)</span>
                </div>

                <div style="margin-top:8px;">
                    <button type="submit" class="btn-save" onclick="return validateAll()">Save Changes</button>
                    <a href="<%= path %>/profile" class="btn-back">← Cancel</a>
                </div>
            </form>
        </div>

        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col"><h3 class="footer-logo">LUXURY FASHION</h3></div>
                <div class="footer-col"><h4>Navigation</h4><ul><li><a href="<%= path %>/home">Home</a></li><li><a href="<%= path %>/products">Shop</a></li></ul></div>
                <div class="footer-col"><h4>Contact</h4><p>Email: hungg8746@gmail.com</p></div>
            </div>
            <div class="footer-bottom"><p>© 2026 Luxury Fashion. All rights reserved.</p></div>
        </footer>

        <script>
            function openMenu() {
                document.getElementById("sideMenu").style.left = "0";
                document.getElementById("overlay").classList.add("active")
            }
            function closeMenu() {
                document.getElementById("sideMenu").style.left = "-280px";
                document.getElementById("overlay").classList.remove("active")
            }

            function validateName() {
                var v = document.getElementById("fullName").value.trim();
                var el = document.getElementById("fullName");
                var msg = document.getElementById("nameMsg");
                if (!v) {
                    el.className = "field-invalid";
                    msg.className = "field-msg msg-err";
                    msg.textContent = "Full name is required.";
                } else {
                    el.className = "field-valid";
                    msg.className = "field-msg msg-ok";
                    msg.textContent = "✓";
                }
            }

            function validateEmail() {
                var v = document.getElementById("email").value.trim().toLowerCase();
                var el = document.getElementById("email");
                var msg = document.getElementById("emailMsg");
                var ok = v.endsWith("@gmail.com") && v.length > "@gmail.com".length;
                if (!ok) {
                    el.className = "field-invalid";
                    msg.className = "field-msg msg-err";
                    msg.textContent = "Must be a Gmail address (e.g. example@gmail.com).";
                } else {
                    el.className = "field-valid";
                    msg.className = "field-msg msg-ok";
                    msg.textContent = "✓";
                }
            }

            function validatePhone() {
                var v = document.getElementById("phone").value.trim();
                var el = document.getElementById("phone");
                var msg = document.getElementById("phoneMsg");
                if (!v) {
                    el.className = "";
                    msg.textContent = "";
                    return;
                }
                var ok = /^0[0-9]{9}$/.test(v);
                if (!ok) {
                    el.className = "field-invalid";
                    msg.className = "field-msg msg-err";
                    msg.textContent = "Must be 10 digits starting with 0 (e.g. 0912345678).";
                } else {
                    el.className = "field-valid";
                    msg.className = "field-msg msg-ok";
                    msg.textContent = "✓";
                }
            }

            function validateAll() {
                validateName();
                validateEmail();
                validatePhone();
                var name = document.getElementById("fullName").value.trim();
                var email = document.getElementById("email").value.trim().toLowerCase();
                var emailOk = email.endsWith("@gmail.com") && email.length > "@gmail.com".length;
                var phone = document.getElementById("phone").value.trim();
                var phoneOk = !phone || /^0[0-9]{9}$/.test(phone);
                return name !== "" && emailOk && phoneOk;
            }
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
