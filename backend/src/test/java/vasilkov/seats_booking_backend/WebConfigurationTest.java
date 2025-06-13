package vasilkov.seats_booking_backend;

import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.servlet.config.annotation.CorsRegistration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import vasilkov.seats_booking_backend.api.WebConfiguration;

import java.lang.annotation.Annotation;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class WebConfigurationTest {

    @Test
    void shouldHaveCorrectAnnotations() {
        // Проверка аннотаций класса
        Annotation[] annotations = WebConfiguration.class.getAnnotations();

        assertTrue(annotations.length >= 2, "Should have at least 2 annotations");
        assertNotNull(WebConfiguration.class.getAnnotation(Configuration.class));
        assertNotNull(WebConfiguration.class.getAnnotation(EnableWebMvc.class));
    }
    @Test
    void shouldImplementWebMvcConfigurer() {
        assertTrue(WebMvcConfigurer.class.isAssignableFrom(WebConfiguration.class));
    }
    @Test
    void shouldAddCorsMappings() {
        // Arrange
        WebConfiguration config = new WebConfiguration();
        CorsRegistry registry = mock(CorsRegistry.class);
        CorsRegistration registration = mock(CorsRegistration.class);

        // Настраиваем моки
        when(registry.addMapping("/**")).thenReturn(registration);
        when(registration.allowedMethods("*")).thenReturn(registration);

        // Act
        config.addCorsMappings(registry);

        // Assert
        verify(registry).addMapping("/**");
        verify(registration).allowedMethods("*");
    }
   
}