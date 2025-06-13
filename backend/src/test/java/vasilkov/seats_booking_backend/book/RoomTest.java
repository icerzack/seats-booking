package vasilkov.seats_booking_backend.book;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import vasilkov.seats_booking_backend.entity.Booking;
import vasilkov.seats_booking_backend.entity.Room;

import java.util.ArrayList;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class RoomTest {

    private Room room;
    private Booking booking1;
    private Booking booking2;

    @BeforeEach
    void setUp() {
        room = Room.builder()
                .id(UUID.randomUUID())
                .name("Conference Room A")
                .booking(new ArrayList<>())
                .build();

        booking1 = Booking.builder()
                .id(UUID.randomUUID())
                .build();

        booking2 = Booking.builder()
                .id(UUID.randomUUID())
                .build();
    }

    @Test
    void addBooking_shouldAddBookingToRoomAndSetRoomForBooking() {
        // Проверяем начальное состояние
        assertTrue(room.getBooking().isEmpty());
        assertNull(booking1.getRoom());

        // Выполняем действие
        room.addBooking(booking1);

        // Проверяем результаты
        assertEquals(1, room.getBooking().size());
        assertTrue(room.getBooking().contains(booking1));
        assertEquals(room, booking1.getRoom());
    }

    @Test
    void addBooking_multipleBookings_shouldAddAllBookings() {
        room.addBooking(booking1);
        room.addBooking(booking2);

        assertEquals(2, room.getBooking().size());
        assertTrue(room.getBooking().contains(booking1));
        assertTrue(room.getBooking().contains(booking2));
        assertEquals(room, booking1.getRoom());
        assertEquals(room, booking2.getRoom());
    }

}
