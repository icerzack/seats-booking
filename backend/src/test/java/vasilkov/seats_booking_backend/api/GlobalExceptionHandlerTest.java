package vasilkov.seats_booking_backend.api;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class GlobalExceptionHandlerTest {

    @InjectMocks
    private GlobalExceptionHandler globalExceptionHandler;

    @Test
    void handleException_shouldReturnBadRequestWithExceptionMessage() {
        // Arrange
        String errorMessage = "Test error message";
        Exception exception = new Exception(errorMessage);

        // Act
        ResponseEntity<String> response = globalExceptionHandler.handleException(exception);

        // Assert
        assertNotNull(response);
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals(errorMessage, response.getBody());
    }

    @Test
    void handleException_withEmptyMessage_shouldReturnBadRequest() {
        // Arrange
        Exception exception = new Exception();

        // Act
        ResponseEntity<String> response = globalExceptionHandler.handleException(exception);

        // Assert
        assertNotNull(response);
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNull(response.getBody());
    }
}