package vasilkov.seats_booking_backend.api;


import org.springframework.web.bind.annotation.*;
import vasilkov.seats_booking_backend.api.request.BookingCreateDTO;
import vasilkov.seats_booking_backend.api.request.BookingUpdateDTO;
import vasilkov.seats_booking_backend.api.response.TimeSlotDTO;
import vasilkov.seats_booking_backend.api.response.UserCodeDTO;
import vasilkov.seats_booking_backend.book.BookingService;
import vasilkov.seats_booking_backend.entity.Booking;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/bookings")
class BookingController {

    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @PostMapping
    public UserCodeDTO create(@RequestBody BookingCreateDTO booking) {
        return bookingService.createBooking(booking);
    }

    @GetMapping("/code")
    public List<Booking> getByUser(@RequestParam String code) {
        return bookingService.getBookingsByCode(code);
    }

    @PutMapping("/{id}")
    public Booking update(@PathVariable UUID id, @RequestBody BookingUpdateDTO booking) {
        return bookingService.updateBooking(id, booking);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        bookingService.deleteBooking(id);
    }

    @GetMapping("/room/{roomId}/availability")
    public List<TimeSlotDTO> getAvailableSlots(@PathVariable UUID roomId, @RequestParam String date) {
        LocalDateTime parsedDate = LocalDateTime.parse(date + "T00:00:00");
        return bookingService.getAvailableTimeSlots(roomId, parsedDate);
    }
}

