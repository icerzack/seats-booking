package vasilkov.seats_booking_backend.book;

import jakarta.transaction.Transactional;
import lombok.Generated;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import vasilkov.seats_booking_backend.api.request.BookingCreateDTO;
import vasilkov.seats_booking_backend.api.request.BookingUpdateDTO;
import vasilkov.seats_booking_backend.api.response.BookingDto;
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
import java.util.*;
import java.util.stream.Collectors;

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

    @Value("${telegram.server.url}")
    private String telegramUrl;

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

        User user = userRepository.findByFio(bookingCreateDTO.getFio())
                .orElseGet(() -> userRepository.save(new User(bookingCreateDTO.getFio())));

        Booking booking = bookingRepository.save(Booking.builder()
                .comment(bookingCreateDTO.getComment())
                .endTime(bookingCreateDTO.getEndTime())
                .startTime(bookingCreateDTO.getStartTime())
                .user(user)
                .room(room).build());

        UserCode userCode = userCodeRepository.findByUser(user)
                .orElseGet(() -> userCodeRepository.save(UserCode.builder().user(user)
                        .code(UUID.randomUUID().toString())
                        .build()));

        sendToTelegramController(booking);
        return UserCodeDTO.builder()
                .code(userCode.getCode())
                .build();
    }

    @Generated
    void sendToTelegramController(Booking booking) {
        RestTemplate restTemplate = new RestTemplate();
        Map<String, Object> bookingData = new LinkedHashMap<>();
        bookingData.put("Пользователь", booking.getUser().getFio());
        bookingData.put("Комната", booking.getRoom().getName());
        bookingData.put("Начало", booking.getStartTime().toString());
        bookingData.put("Окончание", booking.getEndTime().toString());
        bookingData.put("Комментарий", booking.getComment());
        restTemplate.postForEntity(telegramUrl + "/broadcast", bookingData, Void.class);
    }

    @Generated
    public List<Booking> getBookings() {
        return bookingRepository.findAll();
    }

    public List<BookingDto> getBookingsByCode(String code) {
        UserCode userCode = userCodeRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("Invalid code or NO reservations"));
        return bookingRepository.findByUser(userCode.getUser()).stream()
                .map(booking -> {
                    BookingDto bookingDto = new BookingDto();
                    bookingDto.setId(booking.getId());
                    bookingDto.setRoomId(String.valueOf(booking.getRoom().getId()));
                    bookingDto.setStartTime(booking.getStartTime());
                    bookingDto.setEndTime(booking.getEndTime());
                    bookingDto.setComment(booking.getComment());
                    return bookingDto;
                })
                .collect(Collectors.toList());
    }

    public Booking updateBooking(final UUID id, final BookingUpdateDTO bookingUpdateDTO) {
        Room room = roomRepository.findById(bookingUpdateDTO.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room not found"));

        Booking existingBooking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        userCodeRepository.findByUser(existingBooking.getUser())
                .orElseThrow(() -> new RuntimeException("User code not found"));

        existingBooking.setRoom(room);
        existingBooking.setStartTime(bookingUpdateDTO.getStartTime());
        existingBooking.setEndTime(bookingUpdateDTO.getEndTime());
        existingBooking.setComment(bookingUpdateDTO.getComment());

        return bookingRepository.save(existingBooking);
    }

    @Generated
    public void setTelegramUrl(String telegramUrl) {
        this.telegramUrl = telegramUrl;
    }

    public void deleteBooking(UUID id) {
        bookingRepository.deleteById(id);
    }

    public List<TimeSlotDTO> getTimeSlots(final UUID roomId, final LocalDateTime date) {
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


}
