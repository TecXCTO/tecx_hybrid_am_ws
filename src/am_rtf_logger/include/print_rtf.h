#ifndef PRINT_RTF_H
#define PRINT_RTF_H

#include <iostream>
#include <string>

// ANSI/RTF Formatting Codes for Real-Time Kernel Output
#define RTF_RESET        "\033[0m"
#define RTF_BOLD         "\033[1m"
#define RTF_TEXT_CYAN    "\033[36m"
#define RTF_TEXT_GREEN   "\033[32m"
#define RTF_TEXT_YELLOW  "\033[33m"
#define RTF_TEXT_RED     "\033[31m"

class RtfLogger {
public:
    static void log_info(const std::string& component, const std::string& msg) {
        std::cout << RTF_TEXT_GREEN << "[RT-INFO][" << component << "] " << msg << RTF_RESET << std::endl;
    }
    static void log_warn(const std::string& component, const std::string& msg) {
        std::cout << RTF_BOLD << RTF_TEXT_YELLOW << "[RT-WARN][" << component << "] " << msg << RTF_RESET << std::endl;
    }
    static void log_critical(const std::string& component, const std::string& msg) {
        std::cout << RTF_BOLD << RTF_TEXT_RED << "[RT-CRITICAL_FAULT][" << component << "] " << msg << RTF_RESET << std::endl;
    }
};

#endif // PRINT_RTF_H
