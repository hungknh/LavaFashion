/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.User;
import service.AuthService;

import java.io.IOException;

@WebServlet("/auth")
public class AuthController extends HttpServlet {

    private final AuthService authService = new AuthService();

    // ── GET — show forms ───────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            action = "loginForm";
        }

        switch (action) {

            case "loginForm" -> req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);

            case "registerForm" -> req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);

            case "forgotForm" -> req.getRequestDispatcher("/auth/forgot-password.jsp").forward(req, resp);

            case "resetForm" -> // Accessed from email link: /auth?action=resetForm&token=xxxx
                req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);

            case "changeForm" ->  {
                HttpSession session = req.getSession(false);
                if (session == null || session.getAttribute("loggedUser") == null) {
                    resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
                    return;
                }
                req.getRequestDispatcher("/auth/change-password.jsp").forward(req, resp);
            }

            case "logout" ->  {
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
            }

            default -> req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
        }
    }

    // ── POST — handle actions ──────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "login" ->  {
                String username = req.getParameter("username");
                String password = req.getParameter("password");

                User user = authService.login(username, password);

                if (user == null) {
                    req.setAttribute("error", "Incorrect username or password, or account has been disabled.");
                    req.setAttribute("lastUsername", username);
                    req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
                    return;
                }

                // Save to session
                HttpSession session = req.getSession(true);
                session.setAttribute("loggedUser", user);
                session.setMaxInactiveInterval(60 * 60); // 1 hour

                // Redirect based on role
                if (user.isAdmin()) {
                    resp.sendRedirect(req.getContextPath() + "/admin");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/home");
                }
            }
            case "register" ->  {
                String username = req.getParameter("username");
                String password = req.getParameter("password");
                String repassword = req.getParameter("repassword");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String fullName = req.getParameter("fullname");

                String error = authService.register(username, password, repassword,
                        email, phone, fullName);
                if (error != null) {
                    // Keep entered data so user does not have to retype
                    req.setAttribute("error", error);
                    req.setAttribute("lastUsername", username);
                    req.setAttribute("lastEmail", email);
                    req.setAttribute("lastPhone", phone);
                    req.setAttribute("lastFullname", fullName);
                    req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
                    return;
                }

                // Success → redirect to login with success message
                resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm&registered=1");
            }
            case "forgotPassword" ->  {
                String email = req.getParameter("email");

                // Build base URL dynamically
                String baseUrl = req.getScheme() + "://"
                        + req.getServerName() + ":"
                        + req.getServerPort()
                        + req.getContextPath();

                String error = authService.forgotPassword(email, baseUrl);

                if (error != null) {
                    req.setAttribute("error", error);
                    req.setAttribute("lastEmail", email);
                    req.getRequestDispatcher("/auth/forgot-password.jsp").forward(req, resp);
                    return;
                }

                // Always show success (do not reveal if email exists — security)
                req.setAttribute("success",
                        "If that email address is in our system, we've sent a password reset link. "
                        + "Please check your inbox (and spam folder).");
                req.getRequestDispatcher("/auth/forgot-password.jsp").forward(req, resp);
            }
            case "resetPassword" ->  {
                String token = req.getParameter("token");
                String newPass = req.getParameter("newPassword");
                String confirmPass = req.getParameter("confirmPassword");

                String error = authService.resetPassword(token, newPass, confirmPass);

                if (error != null) {
                    req.setAttribute("error", error);
                    req.setAttribute("token", token);
                    req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
                    return;
                }

                // Success → back to login with message
                resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm&reset=1");
            }
            case "changePassword" ->  {
                HttpSession session = req.getSession(false);
                if (session == null || session.getAttribute("loggedUser") == null) {
                    resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
                    return;
                }

                User loggedUser = (User) session.getAttribute("loggedUser");
                String oldPass = req.getParameter("oldPassword");
                String newPass = req.getParameter("newPassword");
                String confirmPass = req.getParameter("confirmPassword");

                String error = authService.changePassword(
                        loggedUser.getUserId(), oldPass, newPass, confirmPass);

                if (error != null) {
                    req.setAttribute("error", error);
                    req.getRequestDispatcher("/auth/change-password.jsp").forward(req, resp);
                    return;
                }

                req.setAttribute("success", "Your password has been updated successfully.");
                req.getRequestDispatcher("/auth/change-password.jsp").forward(req, resp);
            }

            default -> resp.sendRedirect(req.getContextPath() + "/auth?action=loginForm");
        }
        // ── LOGIN ───────────────────────────────────────────────────────
        // ── REGISTER ────────────────────────────────────────────────────
        // ── FORGOT PASSWORD ─────────────────────────────────────────────
        // ── RESET PASSWORD (from email link) ────────────────────────────
        // ── CHANGE PASSWORD (logged in) ─────────────────────────────────
            }
}
