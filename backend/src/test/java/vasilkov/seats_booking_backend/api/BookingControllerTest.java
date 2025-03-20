package vasilkov.seats_booking_backend.api;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import vasilkov.seats_booking_backend.api.request.BookingCreateDTO;
import vasilkov.seats_booking_backend.api.request.BookingUpdateDTO;
import vasilkov.seats_booking_backend.api.response.TimeSlotDTO;
import vasilkov.seats_booking_backend.api.response.UserCodeDTO;
import vasilkov.seats_booking_backend.book.BookingService;
import vasilkov.seats_booking_backend.entity.Booking;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.*;

class BookingControllerTest {

    @Mock
    private BookingService bookingService;

    @InjectMocks
    private BookingController bookingController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void givenBookingCreateDTO_whenCreate_thenReturnUserCodeDTO() {
        // given: подготовка данных для создания брони
        BookingCreateDTO bookingCreateDTO = new BookingCreateDTO();
        UserCodeDTO userCodeDTO = new UserCodeDTO("testСode");

        when(bookingService.createBooking(bookingCreateDTO)).thenReturn(userCodeDTO);

        // when: вызов метода создания брони
        UserCodeDTO result = bookingController.create(bookingCreateDTO);

        // then: проверка, что возвращен UserCodeDTO
        assertNotNull(result);
        assertEquals("testСode", result.getCode());
        verify(bookingService, times(1)).createBooking(bookingCreateDTO);
    }

    @Test
    void givenUserCode_whenGetByUser_thenReturnListOfBookings() {
        // given: подготовка данных для поиска бронирований по коду
        String code = "testСode";
        Booking booking = new Booking();
        List<Booking> bookings = Collections.singletonList(booking);

        when(bookingService.getBookingsByCode(code)).thenReturn(bookings);

        // when: вызов метода поиска бронирований по коду
        List<Booking> result = bookingController.getByUser(code);

        // then: проверка, что возвращен список бронирований
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(booking, result.get(0));
        verify(bookingService, times(1)).getBookingsByCode(code);
    }

    @Test
    void givenBookingUpdateDTO_whenUpdate_thenReturnUpdatedBooking() {
        // given: подготовка данных для обновления брони
        UUID id = UUID.randomUUID();
        BookingUpdateDTO bookingUpdateDTO = new BookingUpdateDTO();
        Booking updatedBooking = new Booking();

        when(bookingService.updateBooking(id, bookingUpdateDTO)).thenReturn(updatedBooking);

        // when: вызов метода обновления брони
        Booking result = bookingController.update(id, bookingUpdateDTO);

        // then: проверка, что возвращена обновленная бронь
        assertNotNull(result);
        assertEquals(updatedBooking, result);
        verify(bookingService, times(1)).updateBooking(id, bookingUpdateDTO);
    }

    @Test
    void givenBookingId_whenDelete_thenBookingIsDeleted() {
        // given: подготовка данных для удаления брони
        UUID id = UUID.randomUUID();
        doNothing().when(bookingService).deleteBooking(id);

        // when: вызов метода удаления брони
        bookingController.delete(id);

        // then: проверка, что метод удаления вызван
        verify(bookingService, times(1)).deleteBooking(id);
    }

    @Test
    void givenRoomIdAndDate_whenGetSlots_thenReturnListOfTimeSlots() {
        // given: подготовка данных для поиска доступных временных слотов
        UUID roomId = UUID.randomUUID();
        String date = "2023-10-01";
        LocalDateTime parsedDate = LocalDateTime.parse(date + "T00:00:00");
        TimeSlotDTO timeSlotDTO = new TimeSlotDTO(LocalTime.of(9, 0), LocalTime.of(10, 0), false);
        List<TimeSlotDTO> timeSlots = Collections.singletonList(timeSlotDTO);

        when(bookingService.getTimeSlots(roomId, parsedDate)).thenReturn(timeSlots);

        // when: вызов метода поиска доступных слотов
        List<TimeSlotDTO> result = bookingController.getSlots(roomId, date);

        // then: проверка, что возвращен список слотов
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(timeSlotDTO, result.get(0));
        verify(bookingService, times(1)).getTimeSlots(roomId, parsedDate);
    }
}