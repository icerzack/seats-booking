package vasilkov.seats_booking_backend.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.proxy.HibernateProxy;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

import static vasilkov.seats_booking_backend.entity.utils.ColumnLength.CL_FIELD_DENORM_DOMAIN;

@RequiredArgsConstructor
@Getter
@Setter
@Entity
@ToString
@Table(name = "booking")
@Builder
@AllArgsConstructor
@EqualsAndHashCode
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, targetEntity = Room.class)
    @JoinColumn(name = "room_id")
    @ToString.Exclude
    @JsonIgnore
    private Room room;

    @ManyToOne(fetch = FetchType.EAGER, targetEntity = User.class)
    @JoinColumn(name = "user_id")
    @ToString.Exclude
    @JsonIgnore
    private User user;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Column(name = "startTime")
    private LocalDateTime startTime;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Column(name = "endTime")
    private LocalDateTime endTime;

    @Column(name = "comment", columnDefinition = "VARCHAR", length = CL_FIELD_DENORM_DOMAIN)
    private String comment;

}
