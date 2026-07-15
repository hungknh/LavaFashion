<%-- 
    Document   : change-password
    Created on : Mar 10, 2026, 8:34:19 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    // Bảo vệ trang — phải đăng nhập mới vào được
    // (AuthFilter sẽ xử lý, nhưng để an toàn check thêm)
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/auth?action=loginForm");
        return;
    }
%>
<!DOCTYPE html >
<html>
    <head>
        <title>Change Password – LAVA</title>

        <style>
            *{
                margin:0;
                padding:0;
                box-sizing:border-box;
                font-family: Arial, Helvetica, sans-serif;
            }
            body{
                background:#f5f5f5;
            }

            /* HEADER */
            .header{
                padding:25px 60px;
                border-bottom:1px solid #ccc;
                background:white;
                display:flex;
                justify-content:space-between;
                align-items:center;
            }
            .logo{
                font-size:48px;
                font-weight:900;
                text-decoration:none;
                color:black;
            }
            .header-user{
                font-size:14px;
                color:#555;
            }
            .header-user a{
                color:black;
                text-decoration:underline;
                margin-left:12px;
            }

            /* CONTAINER */
            .change-container{
                width:500px;
                margin:100px auto;
            }
            .change-container h2{
                font-size:22px;
                letter-spacing:2px;
                margin-bottom:10px;
            }
            .change-container > p{
                font-size:14px;
                color:#555;
                margin-bottom:30px;
                line-height:1.6;
            }

            /* Alert */
            .alert-error{
                background:#fff0f0;
                border:1px solid #f5c6c6;
                color:#c0392b;
                padding:12px 16px;
                margin-bottom:20px;
                font-size:14px;
            }
            .alert-success{
                background:#f0fff4;
                border:1px solid #b2dfdb;
                color:#1a7a4a;
                padding:12px 16px;
                margin-bottom:20px;
                font-size:14px;
            }

            /* INPUT */
            .input-field{
                width:100%;
                padding:18px;
                margin-bottom:16px;
                border:1px solid #999;
                font-size:14px;
                background:white;
                outline:none;
                box-sizing:border-box;
            }
            .input-field:focus{
                border-color:black;
            }

            .input-label{
                font-size:12px;
                font-weight:bold;
                letter-spacing:1px;
                color:#333;
                margin-bottom:6px;
                display:block;
                text-transform:uppercase;
            }

            .pw-hint{
                font-size:12px;
                color:#888;
                margin-top:-10px;
                margin-bottom:16px;
            }

            /* BUTTON */
            button{
                width:100%;
                padding:18px;
                background:black;
                color:white;
                border:none;
                font-size:16px;
                letter-spacing:1px;
                cursor:pointer;
                margin-top:8px;
            }
            button:hover{
                opacity:0.9;
            }

            /* BACK LINK */
            .back-link{
                display:block;
                text-align:center;
                margin-top:20px;
                font-size:14px;
                color:black;
                text-decoration:underline;
            }

            /* DIVIDER */
            .divider{
                border:none;
                border-top:1px solid #ddd;
                margin:25px 0;
            }

            /* FOOTER */
            .footer{
                background:black;
                color:white;
                padding:60px 80px;
                margin-top:80px;
            }
            .footer-container{
                display:flex;
                justify-content:space-between;
            }
            .footer-col{
                width:25%;
            }
            .footer-col h3{
                margin-bottom:15px;
            }
            .footer-col ul{
                list-style:none;
            }
            .footer-col ul li{
                margin-bottom:8px;
            }
            .footer hr{
                margin:40px 0;
                border:0.5px solid #444;
            }
            .copyright{
                text-align:center;
                font-size:14px;
            }
        </style>

        <script>
            function validateChangePassword() {
                const oldPass = document.getElementById('oldPassword').value;
                const newPass = document.getElementById('newPassword').value;
                const confirm = document.getElementById('confirmPassword').value;
                const errDiv = document.getElementById('clientError');

                errDiv.style.display = 'none';

                if (!oldPass.trim()) {
                    errDiv.innerText = 'Please enter your current password.';
                    errDiv.style.display = 'block';
                    return false;
                }
                if (newPass.length < 8 || !/[A-Za-z]/.test(newPass) || !/[0-9]/.test(newPass)) {
                    errDiv.innerText = 'The new password must be at least 8 characters long and include both letters and numbers.';
                    errDiv.style.display = 'block';
                    return false;
                }
                if (newPass === oldPass) {
                    errDiv.innerText = 'The new password must not be the same as the old password.';
                    errDiv.style.display = 'block';
                    return false;
                }
                if (newPass !== confirm) {
                    errDiv.innerText = 'The password doesnt match.';
                    errDiv.style.display = 'block';
                    return false;
                }
                return true;
            }
        </script>
    </head>

    <body>

        <!-- HEADER -->
        <div class="header">
            <a class="logo" href="${pageContext.request.contextPath}/home">LAVA</a>
            <div class="header-user">
                Xin chào, <strong><%= loggedUser.getDisplayName() %></strong>
                <a href="${pageContext.request.contextPath}/profile">My Account</a>
                <a href="${pageContext.request.contextPath}/auth?action=logout">Sign Out</a>
            </div>
        </div>

        <!-- CHANGE PASSWORD -->
        <div class="change-container">

            <h2>CHANGE PASSWORD</h2>
            <p>
                To update your password, please enter your current password first,
                then choose a new strong password.
            </p>

            <hr class="divider">

            <%-- Thông báo lỗi client (JS) --%>
            <div id="clientError" class="alert-error" style="display:none;"></div>

            <%-- Thông báo từ server --%>
            <%
                String error   = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
            %>
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-error"><%= error %></div>
            <% } %>
            <% if (success != null && !success.isEmpty()) { %>
            <div class="alert-success"><%= success %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth"
                  method="post"
                  onsubmit="return validateChangePassword()">
                <input type="hidden" name="action" value="changePassword">

                <label class="input-label" for="oldPassword">Current Password</label>
                <input type="password"
                       id="oldPassword"
                       name="oldPassword"
                       placeholder="Enter current password"
                       class="input-field"
                       required>

                <hr class="divider">

                <label class="input-label" for="newPassword">New Password</label>
                <input type="password"
                       id="newPassword"
                       name="newPassword"
                       placeholder="Create new password"
                       class="input-field"
                       required>
                <p class="pw-hint">At least 8 characters, including both letters and numbers.</p>

                <label class="input-label" for="confirmPassword">Confirm New Password</label>
                <input type="password"
                       id="confirmPassword"
                       name="confirmPassword"
                       placeholder="Confirm new password"
                       class="input-field"
                       required>

                <button type="submit">UPDATE PASSWORD</button>
            </form>

            <a href="${pageContext.request.contextPath}/profile" class="back-link">
                ← Back to My Account
            </a>

        </div>

        <!-- FOOTER -->
        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col">
                    <h3>LAVA</h3>
                    <p>Discover timeless fashion inspired by elegance and modern luxury.</p>
                </div>
                <div class="footer-col">
                    <h3>Navigation</h3>
                    <ul><li>Home</li><li>Shop</li><li>Collection</li><li>About</li></ul>
                </div>
                <div class="footer-col">
                    <h3>Products</h3>
                    <ul><li>Featured</li><li>New</li><li>Best Sellers</li></ul>
                </div>
                <div class="footer-col">
                    <h3>Contact</h3>
                    <ul>
                        <li>Email: hungg8746@gmail.com</li>
                        <li>Phone: 0702285883</li>
                    </ul>
                </div>
            </div>
            <hr>
            <p class="copyright">© 2026 LAVA Fashion. All rights reserved.</p>
        </footer>
       
    </body>
</html>
