package vasilkov.seats_booking_backend.api.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingDto implements Serializable {
    UUID id;
    String roomId;
    LocalDateTime startTime;
    LocalDateTime endTime;
    String comment;
}