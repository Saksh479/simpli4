package com.example.demo.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(HomeController.class)
class HomeControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testHomePage() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(view().name("index"))
                .andExpect(model().attributeExists("message"))
                .andExpect(model().attributeExists("currentTime"))
                .andExpect(model().attributeExists("version"));
    }

    @Test
    void testHealthPage() throws Exception {
        mockMvc.perform(get("/health"))
                .andExpect(status().isOk())
                .andExpect(view().name("health"))
                .andExpect(model().attributeExists("status"))
                .andExpect(model().attributeExists("timestamp"));
    }

    @Test
    void testInfoPage() throws Exception {
        mockMvc.perform(get("/info"))
                .andExpect(status().isOk())
                .andExpect(view().name("info"))
                .andExpect(model().attributeExists("applicationName"))
                .andExpect(model().attributeExists("version"))
                .andExpect(model().attributeExists("javaVersion"));
    }
}
