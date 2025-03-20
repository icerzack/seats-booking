package vasilkov.seats_booking_backend.entity.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vasilkov.seats_booking_backend.entity.Room;

import java.util.UUID;

@Repository
public interface RoomRepository extends JpaRepository<Room, UUID> {
}
