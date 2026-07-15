/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.UserDAO;
import jakarta.mail.MessagingException;
import java.io.UnsupportedEncodingException;
import model.User;
import utils.EmailUtils;
import utils.PasswordUtils;
import utils.ValidationUtils;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.UUID;

public class AuthService {

    private final UserDAO userDAO = new UserDAO();

    // ── Register ──────────────────────────────────────────────────────────
    /**
     * Registers a new user account.
     *
     * @param username desired username (4–30 chars, letters/numbers/underscore)
     * @param password desired password (min 8 chars, letters + numbers)
     * @param repassword password confirmation
     * @param email user email address
     * @param phone user phone number (optional)
     * @param fullName user full name (optional)
     * @return null if successful, error message string if failed
     */
    public String register(String username, String password, String repassword,
            String email, String phone, String fullName) {

        if (!ValidationUtils.notEmpty(username)) {
            return "Username is required.";
        }
        if (!ValidationUtils.isValidUsername(username)) {
            return "Username must be 4–30 characters (letters, numbers, underscore only).";
        }
        if (!ValidationUtils.notEmpty(email)) {
            return "Email is required.";
        }
        if (!ValidationUtils.isValidEmail(email)) {
            return "Invalid email address.";
        }
        if (!ValidationUtils.isStrongPassword(password)) {
            return "Password must be at least 8 characters and include both letters and numbers.";
        }
        if (!password.equals(repassword)) {
            return "Passwords do not match.";
        }
        if (phone != null && !phone.trim().isEmpty() && !ValidationUtils.isValidPhone(phone)) {
            return "Invalid phone number (10 digits, starting with 03/05/07/08/09).";
        }

        try {
            if (userDAO.findByUsername(username.trim()) != null) {
                return "Username '" + username + "' is already taken.";
            }
            if (userDAO.findByEmail(email.trim()) != null) {
                return "Email '" + email + "' is already registered.";
            }

            User user = new User();
            user.setUsername(username.trim());
            user.setPasswordHash(PasswordUtils.hash(password));
            user.setEmail(email.trim());
            user.setPhone(phone != null ? phone.trim() : null);
            user.setFullName(fullName != null ? fullName.trim() : null);

            userDAO.insert(user);
            return null; // success

        } catch (SQLException e) {
            return "A system error occurred. Please try again.";
        }
    }

    // ── Login ─────────────────────────────────────────────────────────────
    /**
     * Authenticates a user by username and password.
     *
     * @param username entered username
     * @param password entered password (plain text)
     * @return User object if successful, null if credentials are wrong or
     * account is disabled
     */
    public User login(String username, String password) {
        if (!ValidationUtils.notEmpty(username) || !ValidationUtils.notEmpty(password)) {
            return null;
        }
        try {
            User user = userDAO.findByUsername(username.trim());
            if (user == null) {
                return null;
            }
            if (!user.isActive()) {
                return null;
            }

            // ← THÊM 2 DÒNG NÀY ĐỂ DEBUG
            System.out.println("🔍 Login attempt | username: " + username);
            System.out.println("🔍 Hash from DB: " + user.getPasswordHash());

            if (!PasswordUtils.verify(password, user.getPasswordHash())) {
                return null;
            }
            return user;
        } catch (SQLException e) {
            return null;
        }
    }

    // ── Forgot Password — send reset email ────────────────────────────────
    /**
     * Generates a reset token and sends a password reset email.
     *
     * @param email email address entered by the user
     * @param baseUrl base URL of the application, e.g.
     * "http://localhost:8080/OnlShop"
     * @return null if successful, error message string if failed
     */
    public String forgotPassword(String email, String baseUrl) {
        if (!ValidationUtils.notEmpty(email)) {
            return "Please enter your email address.";
        }
        if (!ValidationUtils.isValidEmail(email)) {
            return "Invalid email address.";
        }

        try {
            User user = userDAO.findByEmail(email.trim());

            // Always return success — do not reveal whether the email exists (security)
            if (user == null) {
                return null;
            }

            // Generate token, expires in 30 minutes
            String token = UUID.randomUUID().toString().replace("-", "");
            LocalDateTime exp = LocalDateTime.now().plusMinutes(30);

            userDAO.saveResetToken(user.getUserId(), token, exp);

            String resetLink = baseUrl + "/auth?action=resetForm&token=" + token;
            EmailUtils.sendResetEmail(user.getEmail(), resetLink);

            return null; // success

        } catch (MessagingException | UnsupportedEncodingException | SQLException e) {
            return "Failed to send email. Please check your connection and try again.";
        }
    }

    // ── Change Password (logged in) ───────────────────────────────────────
    /**
     * Changes the password for a logged-in user.
     *
     * @param userId ID of the currently logged-in user
     * @param oldPassword current password (plain text)
     * @param newPassword new password (plain text)
     * @param confirmPassword new password confirmation
     * @return null if successful, error message string if failed
     */
    public String changePassword(int userId, String oldPassword,
            String newPassword, String confirmPassword) {

        if (!ValidationUtils.notEmpty(oldPassword)) {
            return "Please enter your current password.";
        }
        if (!ValidationUtils.isStrongPassword(newPassword)) {
            return "New password must be at least 8 characters and include both letters and numbers.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Passwords do not match.";
        }
        if (newPassword.equals(oldPassword)) {
            return "New password must be different from the current password.";
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                return "Account not found.";
            }
            if (!PasswordUtils.verify(oldPassword, user.getPasswordHash())) {
                return "Current password is incorrect.";
            }

            userDAO.updatePassword(userId, PasswordUtils.hash(newPassword));
            return null; // success

        } catch (SQLException e) {
            return "A system error occurred. Please try again.";
        }
    }

    // ── Reset Password (via email token) ──────────────────────────────────
    /**
     * Resets a user's password using a valid reset token from email.
     *
     * @param token reset token from the email link
     * @param newPassword new password (plain text)
     * @param confirmPassword new password confirmation
     * @return null if successful, error message string if failed
     */
    public String resetPassword(String token, String newPassword, String confirmPassword) {
        if (token == null || token.trim().isEmpty()) {
            return "Invalid reset token.";
        }
        if (!ValidationUtils.isStrongPassword(newPassword)) {
            return "Password must be at least 8 characters and include both letters and numbers.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Passwords do not match.";
        }

        try {
            User user = userDAO.findByResetToken(token);
            if (user == null) {
                return "This reset link is invalid or has expired.";
            }

            // ── THÊM ĐOẠN NÀY: Không cho đặt lại mật khẩu cũ ──
            if (PasswordUtils.verify(newPassword, user.getPasswordHash())) {
                return "New password must be different from your old password.";
            }

            boolean updated = userDAO.updatePassword(user.getUserId(), PasswordUtils.hash(newPassword));
            if (!updated) {
                return "Failed to update password. Please try again.";
            }

            userDAO.markTokenUsed(token);
            return null; // success

        } catch (SQLException e) {
            return "A system error occurred. Please try again.";
        }
    }
}
