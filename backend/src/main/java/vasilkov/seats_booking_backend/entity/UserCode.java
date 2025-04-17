package vasilkov.seats_booking_backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@ToString
@Getter
@Setter
@Entity
@Table(name = "user_code")
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode
public class UserCode {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false)
    private UUID id;

    private String code;

    @OneToOne
    @JoinColumn(name = "user_id")
    private User user;
}