package vasilkov.seats_booking_backend;


import org.junit.jupiter.api.Test;
import vasilkov.seats_booking_backend.entity.utils.ColumnLength;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ColumnLengthTest {

    @Test
    void constants_shouldHaveExpectedValues() {
        // Проверка значений констант
        assertEquals(8000, ColumnLength.CL_FIELD_DENORM_DOMAIN);
        assertEquals(2000, ColumnLength.CL_FILED_LENGTH);

        // Дополнительно можно проверить, что значения положительные
        assertTrue(ColumnLength.CL_FIELD_DENORM_DOMAIN > 0);
        assertTrue(ColumnLength.CL_FILED_LENGTH > 0);
    }
}