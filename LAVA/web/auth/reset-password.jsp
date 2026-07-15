<%-- 
    Document   : reset-password
    Created on : Mar 10, 2026, 10:13:57 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Reset Password – LAVA</title>

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

            .reset-container{
                width:500px;
                margin:120px auto;
            }
            .reset-container h2{
                font-size:22px;
                letter-spacing:2px;
                margin-bottom:20px;
            }
            .reset-container > p{
                margin-bottom:25px;
                color:#555;
                font-size:14px;
                line-height:1.6;
            }

            .alert-error{
                background:#fff0f0;
                border:1px solid #f5c6c6;
                color:#c0392b;
                padding:12px 16px;
                margin-bottom:20px;
                font-size:14px;
            }

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

            .pw-hint{
                font-size:12px;
                color:#888;
                margin-top:-10px;
                margin-bottom:16px;
            }

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

            .back-link{
                display:block;
                text-align:center;
                margin-top:20px;
                font-size:14px;
                color:black;
                text-decoration:underline;
            }

            /* Token hết hạn */
            .expired-box{
                background:#fff8e1;
                border:1px solid #ffe082;
                color:#7c5c00;
                padding:20px;
                text-align:center;
                line-height:1.8;
            }
            .expired-box a{
                color:#7c5c00;
                font-weight:bold;
                text-decoration:underline;
            }

            .footer{
                background:black;
                color:white;
                padding:60px 80px;
                margin-top:120px;
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
            function validateReset() {
                const newPass = document.getElementById('newPassword').value;
                const confirm = document.getElementById('confirmPassword').value;
                const errDiv = document.getElementById('clientError');

                errDiv.style.display = 'none';

                if (newPass.length < 8 || !/[A-Za-z]/.test(newPass) || !/[0-9]/.test(newPass)) {
                    errDiv.innerText = 'Passwords must be at least 8 characters long and include both letters and numbers.';
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
        </div>

        <div class="reset-container">

            <h2>SET NEW PASSWORD</h2>

            <%
                String token     = request.getParameter("token");
                String errorAttr = (String) request.getAttribute("error");
                // Nếu không có token → hiện thông báo hết hạn
                boolean hasToken = (token != null && !token.trim().isEmpty());
            %>

            <% if (!hasToken) { %>
            <div class="expired-box">
                <br>The password reset link is invalid or has expired.
                Please <a href="${pageContext.request.contextPath}/auth?action=forgotForm">
                    resend email
                </a>.
            </div>
            <% } else { %>

            <p>Enter your new password below.</p>

            <div id="clientError" class="alert-error" style="display:none;"></div>
            <% if (errorAttr != null && !errorAttr.isEmpty()) { %>
            <div class="alert-error"><%= errorAttr %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth"
                  method="post"
                  onsubmit="return validateReset()">
                <input type="hidden" name="action" value="resetPassword">
                <input type="hidden" name="token"  value="<%= token %>">

                <input type="password"
                       id="newPassword"
                       name="newPassword"
                       placeholder="New password"
                       class="input-field"
                       required>
                <p class="pw-hint">At least 8 characters, including both letters and numbers.</p>

                <input type="password"
                       id="confirmPassword"
                       name="confirmPassword"
                       placeholder="Confirm new password"
                       class="input-field"
                       required>

                <button type="submit">UPDATE PASSWORD</button>
            </form>

            <% } %>

            <a href="${pageContext.request.contextPath}/auth?action=loginForm" class="back-link">
                ← Back to Sign In
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
