package vasilkov.seats_booking_backend.book;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.test.util.ReflectionTestUtils;
import vasilkov.seats_booking_backend.api.request.BookingCreateDTO;
import vasilkov.seats_booking_backend.api.response.BookingDto;
import vasilkov.seats_booking_backend.api.request.BookingUpdateDTO;
import vasilkov.seats_booking_backend.api.response.TimeSlotDTO;
import vasilkov.seats_booking_backend.api.response.UserCodeDTO;
import vasilkov.seats_booking_backend.entity.Booking;
import vasilkov.seats_booking_backend.entity.Room;
import vasilkov.seats_booking_backend.entity.User;
import vasilkov.seats_booking_backend.entity.UserCode;
import vasilkov.seats_booking_backend.entity.repository.BookingRepository;
import vasilkov.seats_booking_backend.entity.repository.RoomRepository;
import vasilkov.seats_booking_backend.entity.repository.UserCodeRepository;
import vasilkov.seats_booking_backend.entity.repository.UserRepository;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class BookingServiceTest {

    @Mock
    private BookingRepository bookingRepository;

    @Mock
    private RoomRepository roomRepository;

    @Mock
    private UserCodeRepository userCodeRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private BookingService bookingService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        ReflectionTestUtils.setField(bookingService, "startHour", 9);
        ReflectionTestUtils.setField(bookingService, "endHour", 18);
    }

    @Test
    void givenBookingCreateDTO_whenCreateBooking_thenReturnUserCodeDTO() {
        // given: подготовка данных для создания брони
        BookingCreateDTO bookingCreateDTO = BookingTestDataFactory.createBookingCreateDTO();
        Room room = BookingTestDataFactory.createRoom(bookingCreateDTO.getRoomId());
        User user = BookingTestDataFactory.createUser(UUID.randomUUID(), bookingCreateDTO.getFio());
        UserCode userCode = BookingTestDataFactory.createUserCode(user, UUID.randomUUID().toString());

        when(roomRepository.findById(bookingCreateDTO.getRoomId())).thenReturn(Optional.of(room));
        when(userRepository.findByFio(bookingCreateDTO.getFio())).thenReturn(Optional.empty());
        when(userRepository.save(any(User.class))).thenReturn(user);
        when(userCodeRepository.findByUser(user)).thenReturn(Optional.empty());
        when(userCodeRepository.save(any(UserCode.class))).thenReturn(userCode);

        // when: вызов метода создания брони
        UserCodeDTO result = bookingService.createBooking(bookingCreateDTO);

        // then: проверка, что возвращен код пользователя и бронь сохранена
        assertNotNull(result);
        assertEquals(userCode.getCode(), result.getCode());
        verify(bookingRepository, times(1)).save(any(Booking.class));
    }

    @Test
    void givenUserCode_whenGetBookingsByCode_thenReturnListOfBookings() {
        // given: подготовка данных для поиска бронирований по коду
        String code = UUID.randomUUID().toString();
        User user = BookingTestDataFactory.createUser(UUID.randomUUID(), "John Doe");
        UserCode userCode = BookingTestDataFactory.createUserCode(user, code);
        Booking booking =
                BookingTestDataFactory.createBooking(
                        UUID.randomUUID(),
                        user,
                        BookingTestDataFactory
                                .createRoom(UUID.randomUUID()), LocalDateTime.now(), LocalDateTime.now().plusHours(1));

        when(userCodeRepository.findByCode(code)).thenReturn(Optional.of(userCode));
        when(bookingRepository.findByUser(user)).thenReturn(List.of(booking));

        // when: вызов метода поиска бронирований по коду
        List<BookingDto> result = bookingService.getBookingsByCode(code);

        // then: проверка, что возвращен список бронирований
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(booking.getId(), result.get(0).getId());
    }

    @Test
    void givenBookingUpdateDTO_whenUpdateBooking_thenReturnUpdatedBooking() {
        // given: подготовка данных для обновления брони
        UUID bookingId = UUID.randomUUID();
        BookingUpdateDTO bookingUpdateDTO = BookingTestDataFactory.createBookingUpdateDTO(
                UUID.randomUUID(),
                LocalDateTime.now().plusHours(1),
                LocalDateTime.now().plusHours(2),
                "Updated booking"
        );

        Room room = BookingTestDataFactory.createRoom(bookingUpdateDTO.getRoomId());
        User user = BookingTestDataFactory.createUser(UUID.randomUUID(), "John Doe");
        Booking existingBooking = BookingTestDataFactory.createBooking(bookingId, user, room, LocalDateTime.now(), LocalDateTime.now().plusHours(1));
        UserCode userCode = BookingTestDataFactory.createUserCode(user, UUID.randomUUID().toString());

        when(roomRepository.findById(bookingUpdateDTO.getRoomId())).thenReturn(Optional.of(room));
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(existingBooking));
        when(userCodeRepository.findByUser(user)).thenReturn(Optional.of(userCode));
        when(bookingRepository.save(existingBooking)).thenReturn(existingBooking);

        // when: вызов метода обновления брони
        Booking result = bookingService.updateBooking(bookingId, bookingUpdateDTO);

        // then: проверка, что бронь обновлена
        assertNotNull(result);
        assertEquals(bookingUpdateDTO.getStartTime(), result.getStartTime());
        assertEquals(bookingUpdateDTO.getEndTime(), result.getEndTime());
        assertEquals(bookingUpdateDTO.getComment(), result.getComment());
    }

    @Test
    void givenBookingId_whenDeleteBooking_thenBookingIsDeleted() {
        // given: подготовка данных для удаления брони
        UUID bookingId = UUID.randomUUID();
        doNothing().when(bookingRepository).deleteById(bookingId);

        // when: вызов метода удаления брони
        bookingService.deleteBooking(bookingId);

        // then: проверка, что метод удаления вызван
        verify(bookingRepository, times(1)).deleteById(bookingId);
    }

    @Test
    void givenRoomIdAndDate_whenGetTimeSlots_thenReturnListOfTimeSlots() {
        // given: подготовка данных для поиска доступных временных слотов
        UUID roomId = UUID.randomUUID();
        LocalDateTime date = LocalDateTime.now().with(LocalTime.of(9, 0));

        Room room = BookingTestDataFactory.createRoom(roomId);
        List<Booking> bookings = BookingTestDataFactory.createBookingsForTimeSlots(room, date);

        when(roomRepository.findById(roomId)).thenReturn(Optional.of(room));
        when(bookingRepository.findByRoomAndStartTimeBetween(room,
                date.with(LocalTime.of(9, 0)),
                date.with(LocalTime.of(18, 0))))
                .thenReturn(bookings);

        // when: вызов метода поиска доступных слотов
        List<TimeSlotDTO> result = bookingService.getTimeSlots(roomId, date);

        // then: проверка, что возвращен список слотов с правильными статусами
        assertNotNull(result);
        assertEquals(9, result.size());
        assertTrue(result.get(1).isBooked());
        assertFalse(result.get(0).isBooked());
    }
}