package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class HomeController {

    @Value("${spring.application.version:1.0.0}")
    private String applicationVersion;

    @Value("${spring.application.name}")
    private String applicationName;

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("message", "Welcome to Spring Boot CI/CD Demo Application!");
        model.addAttribute("currentTime",
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        model.addAttribute("version", applicationVersion);
        model.addAttribute("applicationName", applicationName);
        return "index";
    }

    @GetMapping("/health")
    public String health(Model model) {
        model.addAttribute("status", "Application is running successfully");
        model.addAttribute("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        model.addAttribute("version", applicationVersion);
        model.addAttribute("applicationName", applicationName);
        return "health";
    }

    @GetMapping("/info")
    public String info(Model model) {
        model.addAttribute("applicationName", applicationName);
        model.addAttribute("version", applicationVersion);
        model.addAttribute("buildTime", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        model.addAttribute("javaVersion", System.getProperty("java.version"));
        model.addAttribute("springBootVersion", "3.4.7");
        return "info";
    }
}
