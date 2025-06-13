package vasilkov.seats_booking_backend.api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;
import vasilkov.seats_booking_backend.SeatsBookingBackendApplication;

import static org.mockito.Mockito.mockStatic;

class SeatsBookingBackendApplicationMainTest {

    @Test
    void testMainMethod() {
        // Подменяем SpringApplication.run() для теста
        try (var mocked = mockStatic(SpringApplication.class)) {
            mocked.when(() -> SpringApplication.run(SeatsBookingBackendApplication.class, new String[]{}))
                    .thenReturn(null);

            SeatsBookingBackendApplication.main(new String[]{});

            mocked.verify(() -> SpringApplication.run(SeatsBookingBackendApplication.class, new String[]{}));
        }
    }
}