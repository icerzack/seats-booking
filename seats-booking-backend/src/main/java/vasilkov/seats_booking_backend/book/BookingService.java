package vasilkov.seats_booking_backend.book;

import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import vasilkov.seats_booking_backend.api.request.BookingCreateDTO;
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
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;
    private final RoomRepository roomRepository;
    private final UserCodeRepository userCodeRepository;
    private final UserRepository userRepository;

    @Value("${booking.start.hour:9}")
    private int startHour;

    @Value("${booking.end.hour:18}")
    private int endHour;

    public BookingService(final BookingRepository bookingRepository,
                          final RoomRepository roomRepository,
                          final UserCodeRepository userCodeRepository,
                          final UserRepository userRepository) {
        this.bookingRepository = bookingRepository;
        this.roomRepository = roomRepository;
        this.userCodeRepository = userCodeRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public UserCodeDTO createBooking(BookingCreateDTO bookingCreateDTO) {
        Room room = roomRepository.findById(bookingCreateDTO.getRoomId())
                .orElseThrow(() -> new RuntimeException("NO room existed"));

        validateAndCheckForExistsBooking(room, bookingCreateDTO.getStartTime(), bookingCreateDTO.getEndTime());

        User user = userRepository.findByFio(bookingCreateDTO.getFio())
                .orElseGet(() -> userRepository.save(new User(bookingCreateDTO.getFio())));

        bookingRepository.save(Booking.builder()
                .comment(bookingCreateDTO.getComment())
                .endTime(bookingCreateDTO.getEndTime())
                .startTime(bookingCreateDTO.getStartTime())
                .user(user)
                .room(room).build());

        UserCode userCode = userCodeRepository.findByUser(user)
                .orElseGet(() -> userCodeRepository.save(UserCode.builder().user(user)
                        .code(UUID.randomUUID().toString())
                        .build()));

        return UserCodeDTO.builder()
                .code(userCode.getCode())
                .build();
    }

    public List<Booking> getBookings() {
        return bookingRepository.findAll();
    }

    public List<Booking> getBookingsByCode(String code) {
        UserCode userCode = userCodeRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("Invalid code or NO reservations"));
        return bookingRepository.findByUser(userCode.getUser());
    }

    public Booking updateBooking(final UUID id, final BookingUpdateDTO bookingUpdateDTO) {
        Room room = roomRepository.findById(bookingUpdateDTO.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room not found"));

        Booking existingBooking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        UserCode userCode = userCodeRepository.findByUser(existingBooking.getUser())
                .orElseThrow(() -> new RuntimeException("User code not found"));

        validateUpdateBooking(room, bookingUpdateDTO.getStartTime(), bookingUpdateDTO.getEndTime(), userCode.getUser().getId());

        existingBooking.setRoom(room);
        existingBooking.setStartTime(bookingUpdateDTO.getStartTime());
        existingBooking.setEndTime(bookingUpdateDTO.getEndTime());
        existingBooking.setComment(bookingUpdateDTO.getComment());

        return bookingRepository.save(existingBooking);
    }

    public void deleteBooking(UUID id) {
        bookingRepository.deleteById(id);
    }

    public List<TimeSlotDTO> getAvailableTimeSlots(final UUID roomId, final LocalDateTime date) {
        final Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Room not found"));

        final LocalDateTime startOfDay = date.with(LocalTime.of(startHour, 0));
        final LocalDateTime endOfDay = date.with(LocalTime.of(endHour, 0));

        final List<Booking> bookings = bookingRepository.findByRoomAndStartTimeBetween(room, startOfDay, endOfDay);
        List<TimeSlotDTO> timeSlots = new ArrayList<>();

        LocalDateTime current = startOfDay;
        while (current.isBefore(endOfDay)) {
            LocalDateTime next = current.plusHours(1);
            final LocalDateTime finalCurrent = current;
            boolean isBooked = bookings.stream()
                    .anyMatch(b -> b.getStartTime().isBefore(next) && b.getEndTime().isAfter(finalCurrent));

            timeSlots.add(TimeSlotDTO.builder()
                    .startTime(current.toLocalTime())
                    .endTime(next.toLocalTime())
                    .isBooked(isBooked)
                    .build());
            current = next;
        }
        return timeSlots;
    }

    private void validateAndCheckForExistsBooking(final Room room, LocalDateTime startTime, LocalDateTime endTime) {
        if (endTime.isBefore(startTime) || endTime.isEqual(startTime)) {
            throw new RuntimeException("End time must be after start time");
        }
        boolean isOverlap = bookingRepository.findByRoomAndStartTimeBetween(room, startTime.minusSeconds(1), endTime)
                .stream()
                .anyMatch(booking -> isOverlapping(booking.getStartTime(), booking.getEndTime(), startTime, endTime));

        if (isOverlap) {
            throw new RuntimeException("Room is already booked for the selected time");
        }
    }

    private void validateUpdateBooking(final Room room, LocalDateTime startTime, LocalDateTime endTime, UUID userId) {
        if (endTime.isBefore(startTime) || endTime.isEqual(startTime)) {
            throw new RuntimeException("End time must be after start time");
        }

        List<Booking> conflictingBookings = bookingRepository.findByRoomAndStartTimeBetween(room, startTime.minusSeconds(1), endTime);

        boolean isBookedByOtherUser = conflictingBookings.stream()
                .anyMatch(booking -> !booking.getUser().getId().equals(userId) &&
                        isOverlapping(booking.getStartTime(), booking.getEndTime(), startTime, endTime));

        if (isBookedByOtherUser) {
            throw new RuntimeException("Room is already booked for the selected time by another user");
        }
    }

    private boolean isOverlapping(LocalDateTime existingStart, LocalDateTime existingEnd,
                                  LocalDateTime newStart, LocalDateTime newEnd) {
        return newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart) && !newEnd.isEqual(existingStart);
    }

}
