package vasilkov.seats_booking_backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.proxy.HibernateProxy;

import java.util.List;
import java.util.Objects;
import java.util.UUID;

import static vasilkov.seats_booking_backend.entity.utils.ColumnLength.CL_FILED_LENGTH;

@ToString
@RequiredArgsConstructor
@Getter
@Setter
@Entity
@Table(name = "room")
@Builder
@AllArgsConstructor
public class Room {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    @Column(name = "name", columnDefinition = "VARCHAR", length = CL_FILED_LENGTH)
    private String name;

    @OneToMany(fetch = FetchType.LAZY, orphanRemoval = true, mappedBy = "room", cascade = CascadeType.ALL)
    @ToString.Exclude
    @JsonIgnore
    private List<Booking> booking;

    public void addBooking(Booking newBooking) {
        this.booking.add(newBooking);
        newBooking.setRoom(this);
    }

    public void removeBooking(Booking oldBooking) {
        this.booking.remove(oldBooking);
        oldBooking.setRoom(null);
    }

    @Override
    public final boolean equals(Object o) {
        if (this == o) return true;
        if (o == null) return false;
        Class<?> oEffectiveClass = o instanceof HibernateProxy proxy ? proxy.getHibernateLazyInitializer().getPersistentClass() : o.getClass();
        Class<?> thisEffectiveClass = this instanceof HibernateProxy proxy ? proxy.getHibernateLazyInitializer().getPersistentClass() : this.getClass();
        if (thisEffectiveClass != oEffectiveClass) return false;
        Room room = (Room) o;
        return getId() != null && Objects.equals(getId(), room.getId());
    }

    @Override
    public final int hashCode() {
        return this instanceof HibernateProxy proxy ? proxy.getHibernateLazyInitializer().getPersistentClass().hashCode() : getClass().hashCode();
    }
}