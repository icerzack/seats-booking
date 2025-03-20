package vasilkov.seats_booking_backend.entity.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vasilkov.seats_booking_backend.entity.Booking;
import vasilkov.seats_booking_backend.entity.Room;
import vasilkov.seats_booking_backend.entity.User;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {
    List<Booking> findByRoomAndStartTimeBetween(Room room, LocalDateTime start, LocalDateTime end);

    List<Booking> findByUser(User user);

    boolean existsByRoomAndStartTimeBetween(Room room, LocalDateTime start, LocalDateTime end);
}
