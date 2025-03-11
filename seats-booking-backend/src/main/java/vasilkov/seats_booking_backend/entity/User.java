package vasilkov.seats_booking_backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;
import java.util.UUID;

import static vasilkov.seats_booking_backend.entity.utils.ColumnLength.CL_FIELD_DENORM_DOMAIN;

@ToString
@Getter
@Setter
@Entity
@Table(name = "user_")
@RequiredArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "fio", columnDefinition = "VARCHAR", length = CL_FIELD_DENORM_DOMAIN)
    private String fio; //денормализованное ?

    @OneToMany(fetch = FetchType.LAZY, orphanRemoval = true, mappedBy = "user", cascade = CascadeType.ALL)
    @ToString.Exclude
    @JsonIgnore
    private List<Booking> booking;

    public void addBooking(Booking newBooking) {
        this.booking.add(newBooking);
        newBooking.setUser(this);
    }

    public void removeBooking(Booking oldBooking) {
        this.booking.remove(oldBooking);
        oldBooking.setUser(null);
    }
}