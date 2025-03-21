package vasilkov.seats_booking_backend.book;

import vasilkov.seats_booking_backend.api.request.BookingCreateDTO;
import vasilkov.seats_booking_backend.api.request.BookingUpdateDTO;
import vasilkov.seats_booking_backend.api.response.TimeSlotDTO;
import vasilkov.seats_booking_backend.entity.Booking;
import vasilkov.seats_booking_backend.entity.Room;
import vasilkov.seats_booking_backend.entity.User;
import vasilkov.seats_booking_backend.entity.UserCode;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

/**
 * Класс создан для создания тестовых данных.
 */
public class BookingTestDataFactory {

    public static BookingCreateDTO createBookingCreateDTO() {
        return BookingCreateDTO.builder()
                .roomId(UUID.randomUUID())
                .startTime(LocalDateTime.now().plusHours(1))
                .endTime(LocalDateTime.now().plusHours(2))
                .fio("ФФ ФФ ФФ")
                .comment("Комментарий")
                .build();
    }

    public static BookingUpdateDTO createBookingUpdateDTO(UUID roomId, LocalDateTime startTime, LocalDateTime endTime, String comment) {
        return BookingUpdateDTO.builder()
                .roomId(roomId)
                .startTime(startTime)
                .endTime(endTime)
                .comment(comment)
                .build();
    }

    public static Room createRoom(UUID roomId) {
        return Room.builder()
                .id(roomId)
                .build();
    }

    public static User createUser(UUID userId, String fio) {
        return User.builder()
                .id(userId)
                .fio(fio)
                .build();
    }

    public static UserCode createUserCode(User user, String code) {
        return UserCode.builder()
                .user(user)
                .code(code)
                .build();
    }

    public static Booking createBooking(UUID bookingId, User user, Room room, LocalDateTime startTime, LocalDateTime endTime) {
        return Booking.builder()
                .id(bookingId)
                .user(user)
                .room(room)
                .startTime(startTime)
                .endTime(endTime)
                .comment("Комментарий 2")
                .build();
    }

    public static List<Booking> createBookingsForTimeSlots(Room room, LocalDateTime date) {
        LocalDateTime startTime1 = date.with(LocalTime.of(10, 0));
        LocalDateTime endTime1 = date.with(LocalTime.of(11, 0));

        LocalDateTime startTime2 = date.with(LocalTime.of(14, 0));
        LocalDateTime endTime2 = date.with(LocalTime.of(15, 0));

        User user = createUser(UUID.randomUUID(), "Юзер Ю Ю");

        return List.of(
                createBooking(UUID.randomUUID(), user, room, startTime1, endTime1),
                createBooking(UUID.randomUUID(), user, room, startTime2, endTime2)
        );
    }

    public static TimeSlotDTO createTimeSlotDTO(LocalTime startTime, LocalTime endTime, boolean isBooked) {
        return TimeSlotDTO.builder()
                .startTime(startTime)
                .endTime(endTime)
                .isBooked(isBooked)
                .build();
    }
}