package vasilkov.seats_booking_backend.entity.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vasilkov.seats_booking_backend.entity.User;
import vasilkov.seats_booking_backend.entity.UserCode;

import java.util.Optional;
import java.util.UUID;
@Repository
public interface UserCodeRepository extends JpaRepository<UserCode, UUID> {
    Optional<UserCode> findByCode(String code);
    Optional<UserCode> findByUser(User user);
}