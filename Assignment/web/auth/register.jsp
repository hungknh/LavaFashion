<%-- 
    Document   : register
    Created on : Mar 10, 2026, 8:34:03 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Register – LAVA</title>

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
            }
            .logo{
                font-size:48px;
                font-weight:900;
                text-decoration:none;
                color:black;
            }

            /* REGISTER */
            .register-container{
                width:600px;
                margin:80px auto;
            }
            .register-container h2{
                font-size:22px;
                letter-spacing:2px;
                margin-bottom:20px;
            }
            .register-container > p{
                margin-bottom:10px;
            }
            .benefits{
                margin:15px 0 25px 20px;
            }
            .benefits li{
                margin-bottom:8px;
            }

            /* Thông báo lỗi / thành công — đặt TRÊN form */
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
                padding:16px;
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

            /* Hint mật khẩu */
            .pw-hint{
                font-size:12px;
                color:#888;
                margin-top:-10px;
                margin-bottom:16px;
            }

            /* CHECKBOX */
            .newsletter{
                display:flex;
                align-items:flex-start;
                gap:10px;
                margin:15px 0;
                font-size:14px;
            }
            .newsletter input{
                margin-top:4px;
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

            .login-link{
                margin-top:20px;
                text-align:center;
                font-size:15px;
            }
            .login-link a{
                color:black;
                text-decoration:underline;
                margin-left:5px;
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
            .footer-col p{
                margin-bottom:10px;
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
            // Validate phía client trước khi gửi lên server
            function validateForm() {
                const username = document.getElementById('username').value.trim();
                const email = document.getElementById('email').value.trim();
                const phone = document.getElementById('phone').value.trim();
                const password = document.getElementById('password').value;
                const repass = document.getElementById('repassword').value;
                const errDiv = document.getElementById('clientError');

                errDiv.style.display = 'none';
                errDiv.innerText = '';

                // Username: 4-30 ký tự, chỉ chữ/số/_
                if (!/^[A-Za-z0-9_]{4,30}$/.test(username)) {
                    errDiv.innerText = 'Usernames must be between 4 and 30 characters long and consist only of letters, numbers, and underscores (_).';
                    errDiv.style.display = 'block';
                    return false;
                }

                // Email hợp lệ
                if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                    errDiv.innerText = 'Invalid email address.';
                    errDiv.style.display = 'block';
                    return false;
                }

                // Số điện thoại (nếu nhập)
                if (phone && !/^(03|05|07|08|09)\d{8}$/.test(phone)) {
                    errDiv.innerText = 'Invalid phone number (10 digits, starting with 03/05/07/08/09).';
                    errDiv.style.display = 'block';
                    return false;
                }

                // Mật khẩu >= 8 ký tự, có chữ + số
                if (password.length < 8 || !/[A-Za-z]/.test(password) || !/[0-9]/.test(password)) {
                    errDiv.innerText = 'Passwords must be at least 8 characters long and include both letters and numbers.';
                    errDiv.style.display = 'block';
                    return false;
                }

                // Xác nhận mật khẩu
                if (password !== repass) {
                    errDiv.innerText = 'The verification password doesnt match.';
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
        </div>

        <!-- REGISTER -->
        <div class="register-container">

            <h2>CREATE AN ACCOUNT</h2>

            <p>Creating an account enables you to:</p>
            <ul class="benefits">
                <li>Check out faster</li>
                <li>Keep track of your orders</li>
                <li>Add favorite items to your wish list</li>
            </ul>

            <%-- 1. Lỗi validate từ client (JS) --%>
            <div id="clientError" class="alert-error" style="display:none;"></div>

            <%-- 2. Thông báo lỗi từ server (đặt TRÊN form, không giữa chừng) --%>
            <%
                String serverError = (String) request.getAttribute("error");
                String serverMsg   = (String) request.getAttribute("message");
            %>
            <% if (serverError != null && !serverError.isEmpty()) { %>
            <div class="alert-error"><%= serverError %></div>
            <% } %>
            <% if (serverMsg != null && !serverMsg.isEmpty()) { %>
            <div class="alert-success"><%= serverMsg %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth"
                  method="post"
                  onsubmit="return validateForm()">

                <input type="hidden" name="action" value="register">

                <input type="text"
                       id="fullname"
                       name="fullname"
                       placeholder="Full name"
                       class="input-field"
                       value="<%= request.getAttribute("lastFullname") != null ? request.getAttribute("lastFullname") : "" %>">

                <input type="text"
                       id="username"
                       name="username"
                       placeholder="Username (4–30 ký tự)"
                       class="input-field"
                       value="<%= request.getAttribute("lastUsername") != null ? request.getAttribute("lastUsername") : "" %>"
                       required>

                <input type="email"
                       id="email"
                       name="email"
                       placeholder="Email address"
                       class="input-field"
                       value="<%= request.getAttribute("lastEmail") != null ? request.getAttribute("lastEmail") : "" %>"
                       required>

                <input type="text"
                       id="phone"
                       name="phone"
                       placeholder="Phone number (optional)"
                       class="input-field"
                       value="<%= request.getAttribute("lastPhone") != null ? request.getAttribute("lastPhone") : "" %>">

                <input type="password"
                       id="password"
                       name="password"
                       placeholder="Create a password"
                       class="input-field"
                       required>
                <p class="pw-hint">At least 8 characters, including both letters and numbers.</p>

                <input type="password"
                       id="repassword"
                       name="repassword"
                       placeholder="Verify your password"
                       class="input-field"
                       required>

                <button type="submit">AGREE AND CONTINUE</button>

            </form>

            <div class="login-link">
                Already have an account?
                <a href="${pageContext.request.contextPath}/auth?action=loginForm">Sign in</a>
            </div>

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
                    <ul>
                        <li>Home</li><li>Shop</li><li>Collection</li><li>About</li>
                    </ul>
                </div>
                <div class="footer-col">
                    <h3>Products</h3>
                    <ul>
                        <li>Featured</li><li>New</li><li>Best Sellers</li>
                    </ul>
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
