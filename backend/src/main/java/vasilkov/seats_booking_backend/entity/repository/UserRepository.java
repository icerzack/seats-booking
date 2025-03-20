package vasilkov.seats_booking_backend.entity.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vasilkov.seats_booking_backend.entity.User;
import java.util.Optional;

import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByFio(String fio);
}
