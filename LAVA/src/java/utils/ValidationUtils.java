/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import java.util.regex.Pattern;

public class ValidationUtils {

    // Email hợp lệ
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        String regex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return Pattern.matches(regex, email.trim());
    }

    // Số điện thoại VN hợp lệ (10 số, bắt đầu 03/05/07/08/09)
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return true; // phone không bắt buộc
        }
        String regex = "^(03|05|07|08|09)\\d{8}$";
        return Pattern.matches(regex, phone.trim());
    }

    // Mật khẩu mạnh: >= 8 ký tự, có chữ + số
    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasLetter = password.chars().anyMatch(Character::isLetter);
        boolean hasDigit = password.chars().anyMatch(Character::isDigit);
        return hasLetter && hasDigit;
    }

    // Username hợp lệ: 4-30 ký tự, chỉ chữ/số/dấu _
    public static boolean isValidUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        String regex = "^[A-Za-z0-9_]{4,30}$";
        return Pattern.matches(regex, username.trim());
    }

    // Không rỗng
    public static boolean notEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
